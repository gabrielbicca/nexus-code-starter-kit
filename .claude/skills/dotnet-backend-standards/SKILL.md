---
name: dotnet-backend-standards
description: Padrão de backend .NET para o kit — .NET 10 (LTS) / C# 14, ASP.NET Core (Controllers), Domain-Driven Design + Clean Architecture, exceções tipadas, FluentValidation, JWT, Scalar/OpenAPI, Serilog, cultura pt-BR e baseline de segurança obrigatório. Carregue ao projetar ou implementar qualquer código de backend dotnet, revisar PR ou tomar decisão de arquitetura no servidor.
---

# Backend Standards (.NET 10 LTS — DDD + Clean)

> Padrão de codificação para serviços backend em .NET. Camadas, exceções tipadas e baseline de segurança são **obrigatórios** — verificados em code review.

## Stack
.NET 10 (LTS) · C# 14 · ASP.NET Core (Controllers) · SQL Server · JWT Bearer ·
Scalar (OpenAPI nativo) · MS DI · FluentValidation · Serilog + Seq (dev)/Azure Monitor (prod) ·
xUnit + Moq + FluentAssertions (unit) · WebApplicationFactory (integração) · HealthChecks ·
Azure DevOps CI/CD. **Instale somente os pacotes NuGet realmente usados.**

> **LTS sempre.** Use a versão LTS do .NET vigente (.NET 8 e .NET 10 são LTS; .NET 9 é STS).
> Para um projeto novo, prefira o LTS mais recente. ORMs e pacotes acompanham a major do framework.

ORM: EF Core **ou** Dapper — veja as skills [`dotnet-orm-efcore`](../dotnet-orm-efcore/SKILL.md) e [`dotnet-orm-dapper`](../dotnet-orm-dapper/SKILL.md).
Divisão padrão: EF Core para escritas, Dapper para leituras complexas/relatórios/exports.

## Camadas (dependência aponta para dentro)
`Api → Application → Domain ← Infrastructure`. O Domain não conhece nenhuma outra camada.
```
src/
  MyApp.Domain/         Entities, ValueObjects, Enums, Interfaces/Repositories, Exceptions
  MyApp.Application/    DTOs, UseCases, Validators, Mappings, DependencyInjection
  MyApp.Infrastructure/ Data (DbContext, Configurations, Migrations, Repositories),
                        ExternalServices, DependencyInjection
  MyApp.Api/            Controllers, Middlewares, Extensions, Program.cs, appsettings
tests/                  Domain.Tests, Application.Tests, Api.Tests
```

## Domain
- Entidades derivam de `Entity` (`int Id`, igualdade por identidade). Construtor protegido para o EF;
  regras impostas em construtores/métodos (lançam `DomainException` na violação).
- Value Objects derivam de `ValueObject` (imutáveis, igualdade por valor), ex. `CPF`.
- Interfaces de repositório ficam no Domain, implementadas na Infrastructure.

## Padrão de exceções (sem try/catch em UseCases/Controllers)
Exceções tipadas → `ExceptionHandlerMiddleware` global → `ErrorResponse` padronizado.

| Exceção | HTTP | campo `error` |
|---|---|---|
| `ValidationException` | 400 | "Erro de Validação" |
| `NotFoundException` | 404 | "Não Encontrado" |
| `DomainException` | 422 | "Regra de Negócio" |
| `UnauthorizedException` | 401 | "Não Autenticado" |
| `ForbiddenException` | 403 | "Acesso Negado" |
| (não tratada) | 500 | "Erro Interno do Servidor" |

`AppException` é a base abstrata que carrega `StatusCode`. `ErrorResponse` é um record:
`(int Status, string Error, string Message, IDictionary<string,string[]>? Errors, string? TraceId)`.
Stack traces são logados internamente apenas — nunca retornados ao cliente.

## Application
- DTOs são `record`s; nunca exponha entidades EF pela API.
- Mapeamento manual via extension methods (sem AutoMapper).
- UseCases lançam exceções tipadas diretamente; dependem só de interfaces do Domain — nunca de
  `HttpContext`/`IConfiguration`/infraestrutura (mantém testabilidade unitária).
- FluentValidation na borda; um `ValidationFilter` converte falhas em `ValidationException`.

## API
- Controllers finos: delegam para UseCases, sem lógica de negócio, sem `try/catch`.
- XML docs (`///`) e `[ProducesResponseType]` em todo endpoint público.
- Ordem no `Program.cs`: `SecurityHeadersMiddleware` → `ExceptionHandlerMiddleware` →
  `UseHttpsRedirection` → `UseHsts` → `UseRateLimiter` → `UseAuthentication` → `UseAuthorization`
  → `MapControllers`. Scalar UI em `/scalar/v1` no Development.
- Cultura pt-BR no `Program.cs` (`CultureInfo("pt-BR")` como cultura padrão de thread + UI).

## Baseline de segurança (obrigatório — verificado em code review)
- HTTPS + `UseHsts()`; `SecurityHeadersMiddleware` primeiro (X-Content-Type-Options nosniff,
  X-Frame-Options DENY, Referrer-Policy no-referrer, Permissions-Policy, HSTS, CSP; remove
  Server/X-Powered-By).
- Rate limiting nativo: `default` 60/min/IP; estrito `auth` 5/min em login/reset; 429 retorna
  `ErrorResponse` com `Retry-After`.
- JWT: `ClockSkew = TimeSpan.Zero`; access token ≤ 15 min em prod; rotação de refresh token;
  secret ≥ 256-bit do Key Vault (prod)/User Secrets (dev); `OnChallenge`/`OnForbidden` lançam as
  exceções tipadas para passarem pelo middleware de erro.
- Autorização: políticas RBAC + `[Authorize(Policy="...")]` explícito; **IDOR** — sempre verifique
  que o recurso pertence à identidade do JWT; nunca confie num ID vindo de body/query.
- SQL injection: parametrizado sempre (EF Core / Dapper `@params` / `FromSqlRaw` com params);
  usuário de banco com menor privilégio; Managed Identity quando possível.
- Logging: nunca logar secrets/tokens/connection strings; mascarar CPF/CNPJ; suprimir logs de SQL
  do EF (`MinimumLevel.Override("Microsoft.EntityFrameworkCore.Database.Command", Warning)`).
- Validação de entrada: allowlist em vez de denylist; revalide tudo no servidor.
- Dependências: `dotnet list package --vulnerable --include-transitive` limpo de críticos.
- Secrets: Azure Key Vault em prod; nunca commitar `appsettings.Production.json` com secrets.

## Testes
- DI em tudo (sem `new` de dependências no código de negócio).
- Cobrir happy path, erro de domínio e not-found; ≥ 80% de cobertura em Domain + Application.
- Injete um clock para testes determinísticos baseados em tempo.

## `.editorconfig`
Indentação 4 espaços, CRLF, UTF-8-BOM, campos privados `_camelCase`, chaves obrigatórias, `var`
só quando o tipo é aparente, usings de `System` primeiro.

## Checklist de code review
Nomes de responsabilidade única · sem lógica de negócio fora do Domain · sem acesso a banco fora da
Infrastructure · sem `try/catch` fora do middleware · sem duplicação · sem números/strings mágicos ·
dependências atrás de interfaces · testes de 3 cenários · sem secrets hardcoded · XML docs em
endpoints públicos · checklist de segurança acima aprovado.

---
**Relacionadas:** [`dotnet-orm-efcore`](../dotnet-orm-efcore/SKILL.md) (escritas) · [`dotnet-orm-dapper`](../dotnet-orm-dapper/SKILL.md) (leituras) · [`dotnet-project-scaffold`](../dotnet-project-scaffold/SKILL.md) (gerar a estrutura). Para scaffolding rápido use o command `/dotnet-new`.
