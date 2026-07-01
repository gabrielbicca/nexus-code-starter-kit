---
name: dotnet-project-scaffold
description: Gerar a estrutura de um projeto backend .NET novo a partir de um de dois padrões — clean (Clean Architecture + DDD, .NET 10 LTS) ou ntier (N-Tier em camadas, .NET 8 LTS). Carregue ao criar um projeto/solução dotnet do zero, adicionar um novo serviço ou portal, ou decidir entre arquitetura limpa e N-Tier. O command /dotnet-new automatiza estes passos.
---

# Scaffold de Projeto .NET (clean | ntier)

> Cria a árvore de projetos, `.sln`, `.csproj` e arquivos mínimos (`Program.cs`/`Startup.cs`) de um
> backend .NET seguindo um de dois padrões. **Sempre usa versões LTS** do framework e ORMs.
> Esta skill é a referência; o command `/dotnet-new` executa o scaffolding.

## Escolha do padrão

```
Projeto novo, greenfield, regras de domínio ricas, API/microserviço?
  → pattern clean   (Clean Architecture + DDD, .NET 10 LTS)

Encaixar numa solução N-Tier em camadas (MVC + WebAPI), múltiplos portais
compartilhando backend, stored procedures, SignalR/componentes de UI de terceiros?
  → pattern ntier   (N-Tier em camadas, .NET 8 LTS)
```

| | **clean** | **ntier** |
|---|---|---|
| Framework | .NET 10 (LTS) | .NET 8 (LTS) |
| Arquitetura | Clean + DDD | N-Tier / Layered |
| ORM | EF Core 10 (write) + Dapper (read) | EF Core 8 + Dapper 2.x |
| API | ASP.NET Core Controllers + OpenAPI/Scalar | MVC + WebAPI (Razor) |
| Entidades | `Entity`/`ValueObject`, DTOs como `record` | `tbl`-prefix + `*Aux` DTOs |
| Serviços | UseCases (Application) | `I*Business` / `*Business` |
| Erros | exceções tipadas + middleware | retorno `Task<dynamic>` |
| Bootstrap | `Program.cs` minimal hosting | `Program.cs` + `Startup.cs` |
| Skills de apoio | [`dotnet-backend-standards`](../dotnet-backend-standards/SKILL.md), [`dotnet-orm-efcore`](../dotnet-orm-efcore/SKILL.md), [`dotnet-orm-dapper`](../dotnet-orm-dapper/SKILL.md) | as mesmas, adaptadas a N-Tier |

> **Regra LTS:** nunca scaffolde em STS. .NET 8 e .NET 10 são LTS; .NET 9 é STS.
> Para `clean`, prefira o LTS mais recente (.NET 10). Para `ntier`, alinhe ao LTS da solução-alvo
> existente (tipicamente .NET 8). Os pacotes EF Core acompanham a major do framework.

---

## Padrão `clean` — Clean Architecture + DDD (.NET 10 LTS)

Segue integralmente [`dotnet-backend-standards`](../dotnet-backend-standards/SKILL.md).

### Estrutura
```
<Nome>/
├── <Nome>.sln
├── src/
│   ├── <Nome>.Domain/          Entities, ValueObjects, Enums, Interfaces/Repositories, Exceptions
│   ├── <Nome>.Application/      DTOs, UseCases, Validators, Mappings, DependencyInjection.cs
│   ├── <Nome>.Infrastructure/   Data (DbContext, Configurations, Migrations, Repositories),
│   │                            ExternalServices, DependencyInjection.cs
│   └── <Nome>.Api/              Controllers, Middlewares, Extensions, Program.cs, appsettings.json
├── tests/
│   ├── <Nome>.Domain.Tests/
│   ├── <Nome>.Application.Tests/
│   └── <Nome>.Api.Tests/
├── .editorconfig
└── Directory.Build.props        TargetFramework=net10.0, LangVersion, Nullable=enable
```

### Passos
1. `dotnet new sln -n <Nome>`
2. Criar os 4 projetos src/:
   - `dotnet new classlib -n <Nome>.Domain -o src/<Nome>.Domain -f net10.0`
   - `dotnet new classlib -n <Nome>.Application -o src/<Nome>.Application -f net10.0`
   - `dotnet new classlib -n <Nome>.Infrastructure -o src/<Nome>.Infrastructure -f net10.0`
   - `dotnet new webapi -n <Nome>.Api -o src/<Nome>.Api -f net10.0 --use-controllers`
3. Referências (dependência aponta para dentro): `Api → Application → Domain`, `Infrastructure → Domain`, `Api → Infrastructure` (só para DI).
4. Projetos de teste: `dotnet new xunit` para cada, referenciando o projeto sob teste.
5. Pacotes (só os usados): EF Core 10 + `.Tools`/`.Design` na Infrastructure; `Dapper` + `Microsoft.Data.SqlClient` se houver leitura complexa; `FluentValidation`, `Serilog.AspNetCore`, `Scalar.AspNetCore`, JWT no Api/Application conforme necessário.
6. `Program.cs` na ordem de middleware do `dotnet-backend-standards` (SecurityHeaders → ExceptionHandler → HTTPS/HSTS → RateLimiter → AuthN → AuthZ → MapControllers), cultura pt-BR, Scalar em Development.
7. Adicionar todos ao `.sln` e `dotnet build`.

---

## Padrão `ntier` — N-Tier em camadas (.NET 8 LTS)

Camadas com dependência linear; backend compartilhado por múltiplos portais web.

### Estrutura
```
<Nome>/
├── <Nome>.sln
├── <Nome>.ENTITY/        Tables/ (entidades EF, tbl-prefix), Generic/ (DTOs *Aux)
├── <Nome>.DATA/          <Nome>Context.cs (DbContext), Dapper/ (DapperHelper + IDapperHelper), Util/
├── <Nome>.BUSINESS/      Business/ (*Business.cs), IBusiness/ (I*Business.cs), Security/, Hubs/
├── <Nome>.LANGUAGE/      Resources/ (Resource.resx — pt-BR, en-US)
└── <Nome>.WEB/           Controllers/, WebAPI/, Views/, Models/, Reports/, Util/, wwwroot/,
                          Program.cs, Startup.cs, appsettings.json
```
Camadas: `WEB → BUSINESS → DATA → ENTITY` (+ `LANGUAGE` transversal). Portais adicionais
(`<Nome>.<Portal>.WEB`) referenciam BUSINESS/DATA/ENTITY/LANGUAGE via `<ProjectReference>`.

### Convenções (N-Tier)
- Entidades: `tbl` + PascalCase (`tblExemplo`), PK `IDItem`, flags `byte` (0/1), FKs nullable.
- DTO/Aux: `tblExemploAux : tblExemplo` em `Generic/`.
- Serviço: par `IExemploBusiness : IDisposable` (em `IBusiness/`) + `ExemploBusiness` (em `Business/`), DI por construtor, métodos `Task<dynamic>`/`Task<List<dynamic>>`.
- Dados: EF Core para queries simples; `IDapperHelper.ExecuteQuery("sp_...", parms)` para stored procedures/queries complexas. `DbContext` com `CommandTimeout` + `UseCompatibilityLevel` conforme o banco-alvo.
- Web: `BaseController : Controller` (MVC, sessão) e `BaseApiController : ControllerBase` (token); filtros `[AuthorizationFilter]`/`[TokenAuthentication]`.

### Passos
1. `dotnet new sln -n <Nome>`
2. Camadas: `dotnet new classlib -n <Nome>.ENTITY -f net8.0` (idem DATA, BUSINESS, LANGUAGE).
3. Web: `dotnet new mvc -n <Nome>.WEB -f net8.0`.
4. Referências: WEB → BUSINESS, DATA, ENTITY, LANGUAGE; BUSINESS → DATA, ENTITY; DATA → ENTITY.
5. Pacotes: `Microsoft.EntityFrameworkCore.SqlServer` + `Dapper` (DATA); Telerik/SignalR/Newtonsoft conforme o portal precisar.
6. `Program.cs` + `Startup.cs` (hosting clássico): registrar `I*Business`/`IDapperHelper` como Scoped, `IHttpContextAccessor` Singleton, `AddDbContext`, `AddSignalR`/Telerik se usados; mapear Hubs e rota default.
7. Para um **novo portal**: `dotnet new mvc -n <Nome>.<Portal>.WEB` e referenciar as mesmas 4 camadas de backend.
8. Adicionar todos ao `.sln` e `dotnet build`.

---

## Depois de gerar
- Registre a decisão de padrão num ADR (`/adr`) e a estrutura numa SPEC (`/spec`) — o kit é spec-driven.
- Implemente o backend seguindo [`dotnet-backend-standards`](../dotnet-backend-standards/SKILL.md) + a skill de ORM apropriada.
- Confirme com `dotnet build` antes de afirmar que está pronto.

## Erros comuns
- Scaffoldar em STS (.NET 9) → use LTS.
- Referência de camada invertida no `clean` (Domain dependendo de outra camada) → Domain não referencia ninguém.
- Instalar todo o EF + Dapper + Telerik "por padrão" → instale só os pacotes que o projeto usa.
- Misturar `clean` e `ntier` no mesmo serviço → escolha um por solução.
