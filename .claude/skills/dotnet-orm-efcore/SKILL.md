---
name: dotnet-orm-efcore
description: Convenções de Entity Framework Core (LTS) para backend dotnet — setup do DbContext, configuração via Fluent API com IEntityTypeConfiguration (sem Data Annotations), repositories, query filters de soft-delete, AsNoTracking e Include explícito, migrations e mapeamentos de tipo do SQL Server. Carregue ao implementar ou revisar acesso a dados de escrita com EF Core, configuração de entidade ou migrations.
---

# EF Core (LTS) — Standards

> Papel padrão: **escritas** (insert/update/delete com regras de domínio) e domínios modelados em
> objetos. Para leituras complexas/relatórios/exports use Dapper (veja [`dotnet-orm-dapper`](../dotnet-orm-dapper/SKILL.md)).
> Os dois podem coexistir no mesmo projeto.

> **Versão = a major LTS do framework.** EF Core 10 para .NET 10; EF Core 8 para .NET 8.
> Mantenha `Microsoft.EntityFrameworkCore.*` alinhados à mesma major do runtime.

## Pacotes
`Microsoft.EntityFrameworkCore.SqlServer`, `.Tools`, `.Design` (todos na major LTS, ex. `10.*`).

## DbContext
```csharp
public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }
    public DbSet<Solicitacao> Solicitacoes => Set<Solicitacao>();
    protected override void OnModelCreating(ModelBuilder b)
    {
        b.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly); // todos IEntityTypeConfiguration
        base.OnModelCreating(b);
    }
}
```

## Configuração de entidade (só Fluent API — nunca Data Annotations)
Uma `IEntityTypeConfiguration<T>` por entidade. Sempre defina: nome de tabela explícito, chave, strings
como `VARCHAR(n)` via `HasColumnType` (nunca deixe o EF inferir `NVARCHAR`), datas como `DATETIME2`,
enums `HasConversion<string>()`, colunas de auditoria + soft-delete, e o query filter de soft-delete:
```csharp
builder.ToTable("Solicitacao");
builder.HasKey(x => x.Id);
builder.Property(x => x.Status).IsRequired().HasMaxLength(40)
       .HasColumnType("VARCHAR(40)").HasConversion<string>();
builder.Property(x => x.CriadoEm).IsRequired().HasColumnType("DATETIME2");
builder.Property(x => x.Excluido).IsRequired().HasDefaultValue(false);
builder.HasQueryFilter(x => !x.Excluido);                 // linhas soft-deleted nunca aparecem
builder.HasOne(x => x.Beneficiario).WithMany()
       .HasForeignKey(x => x.BeneficiarioId)
       .OnDelete(DeleteBehavior.Restrict);                // CASCADE é proibido
builder.HasIndex(x => x.Status).HasDatabaseName("IX_Solicitacao_Status");
```

## Repository
- `FindAsync` para by-id; `AsNoTracking()` para queries read-only; soft delete via o método
  `Excluir(...)` da entidade, nunca delete físico. Use `.IgnoreQueryFilters()` só para leituras de auditoria.
```csharp
public async Task<Solicitacao?> GetByIdAsync(int id, CancellationToken ct = default)
    => await _ctx.Solicitacoes.FindAsync([id], ct);
public async Task<IEnumerable<Solicitacao>> GetAllAsync(CancellationToken ct = default)
    => await _ctx.Solicitacoes.AsNoTracking().ToListAsync(ct);
```

## Boas práticas de query
- `AsNoTracking()` para read-only; projete com `Select` para evitar over-fetching.
- **`Include` explícito** — lazy loading é proibido em produção (causa N+1).
- Pagine no servidor (page size 20) em qualquer listagem.

## DI
```csharp
services.AddDbContext<AppDbContext>(o =>
    o.UseSqlServer(config.GetConnectionString("DefaultConnection"), sql => sql.CommandTimeout(30)));
services.AddScoped<ISolicitacaoRepository, SolicitacaoRepository>();
```

## Migrations
```bash
dotnet ef migrations add <Name> --project MyApp.Infrastructure --startup-project MyApp.Api
dotnet ef database update          --project MyApp.Infrastructure --startup-project MyApp.Api
dotnet ef migrations script --idempotent -o migrations.sql --project MyApp.Infrastructure --startup-project MyApp.Api
```
Nomes: `Create{Table}`, `Add{Col}To{Table}`, `Remove{Col}From{Table}`, `Alter{Col}In{Table}`,
`AddIndex{Col}To{Table}`, `Seed{Entity}`. Regras: implemente `Down()` sempre; migrations carregam só
DDL + seeds de referência (sem lógica de negócio); **produção aplica o script SQL idempotente via
CI/CD**; revise o SQL gerado antes; `RenameColumn`/`RenameTable` exigem análise de impacto.

## Convenções
Só Fluent API · sem lazy loading · `AsNoTracking()` em leituras · `HasQueryFilter(!Excluido)` para
entidades soft-deletable · `DeleteBehavior.Restrict` sempre · `VARCHAR(n)` + `DATETIME2` explícitos ·
enums como string · migrations de prod via script idempotente.

---
**Relacionadas:** [`dotnet-backend-standards`](../dotnet-backend-standards/SKILL.md) (arquitetura/segurança) · [`dotnet-orm-dapper`](../dotnet-orm-dapper/SKILL.md) (leituras complexas).
