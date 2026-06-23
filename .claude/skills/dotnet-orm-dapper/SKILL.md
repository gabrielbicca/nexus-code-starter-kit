---
name: dotnet-orm-dapper
description: Convenções de Dapper para backend dotnet — quando usar Dapper vs EF Core, IDbConnection scoped, read repositories, SQL raw parametrizado, filtro de soft-delete, multi-mapping, stored procedures, transações explícitas e TypeHandlers de enum. Carregue ao implementar ou revisar acesso a dados de leitura, relatórios, exports financeiros ou qualquer SQL complexo/de alta performance.
---

# Dapper — Standards

> Papel padrão: **leituras** — queries multi-join complexas, relatórios/dashboards, exports
> financeiros, acesso a banco legado sem migrations e stored procedures. Use EF Core para escritas
> com regras de domínio (veja [`dotnet-orm-efcore`](../dotnet-orm-efcore/SKILL.md)). EF Core (escrita) +
> Dapper (leitura) podem coexistir num projeto; `AppDbContext` e `IDbConnection` vivem na Infrastructure.

| Use Dapper | Use EF Core |
|---|---|
| Leituras multi-JOIN complexas, relatórios, exports | Escritas com regras de domínio |
| Acesso a banco legado sem migrations | Domínios novos modelados em objetos |
| Stored procedures existentes | — |
| Leitura de alta performance com SQL controlado | — |

## Pacotes
`Dapper` (2.*), `Microsoft.Data.SqlClient` (alinhado ao runtime), opcionalmente `Dapper.SqlBuilder`.

## Connection (Scoped — uma por request HTTP)
```csharp
services.AddScoped<IDbConnection>(_ => new SqlConnection(config.GetConnectionString("DefaultConnection")!));
services.AddScoped<ISolicitacaoReadRepository, SolicitacaoReadRepository>();
```

## Regras
- **Só parametrizado** — `@params` nomeados; nunca concatene input do usuário. (SQL injection é falha grave.)
- Sempre inclua o filtro de soft-delete `AND Excluido = 0` nas queries de leitura.
- Passe `CancellationToken` via `CommandDefinition`.
- Use raw string literals (`"""..."""`) para SQL legível.
- Separe **read repositories** (`IReadRepository`) dos write repositories — clareza de intenção.
- Dapper abre/fecha a conexão automaticamente; abra manualmente só para transações explícitas.

## Read repository + multi-mapping
```csharp
const string sql = """
    SELECT p.Id, p.Descricao, p.Status, p.CriadoEm,
           i.Id AS ItemId, i.Descricao AS ItemDescricao
    FROM   Solicitacao p
    INNER JOIN ItemSolicitacao i ON i.SolicitacaoId = p.Id
    WHERE  p.Id = @Id AND p.Excluido = 0
    """;
var dict = new Dictionary<int, SolicitacaoDetalhadaDto>();
await _conn.QueryAsync<SolicitacaoDetalhadaDto, ItemDto, SolicitacaoDetalhadaDto>(
    new CommandDefinition(sql, new { Id = id }, cancellationToken: ct),
    (s, item) => { /* agrega items em s */ return s; },
    splitOn: "ItemId");
```

## Stored procedures (ex. geração de relatório)
```csharp
await _conn.QueryAsync<RelatorioDto>(new CommandDefinition(
    "sp_RelatorioPagamentos", new { DataInicio, DataFim },
    commandType: CommandType.StoredProcedure, cancellationToken: ct));
```

## Transações explícitas (escritas multi-tabela quando não usar EF Core)
Abra a conexão, `BeginTransaction()`, passe a transação em cada `CommandDefinition`,
`Commit()` no sucesso, `Rollback()` no `catch`, e relance.

## Enum TypeHandler (enums armazenados como VARCHAR)
Registre uma vez no startup: `SqlMapper.AddTypeHandler(new StatusTypeHandler());` com
`SetValue` → `value.ToString()` e `Parse` → `Enum.Parse<T>(...)`.

## Convenções
SQL raw `"""..."""` · `AND Excluido = 0` nas leituras · só `@params` nomeados (sem concatenação) ·
`CancellationToken` via `CommandDefinition` · `IDbTransaction` explícita para escritas multi-tabela ·
`CommandType.StoredProcedure` para procs · `TypeHandler` de enum registrado no startup · read
repository separado · `IDbConnection` scoped.

---
**Relacionadas:** [`dotnet-backend-standards`](../dotnet-backend-standards/SKILL.md) (arquitetura/segurança) · [`dotnet-orm-efcore`](../dotnet-orm-efcore/SKILL.md) (escritas).
