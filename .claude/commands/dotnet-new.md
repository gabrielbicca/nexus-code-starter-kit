---
description: Gera a estrutura de um projeto backend .NET novo a partir de um padrão — clean (Clean Architecture + DDD, .NET 10 LTS) ou wafx (N-Tier em camadas, padrão WAFX, .NET 8 LTS). Sempre usa versões LTS. Use ao iniciar um projeto/solução dotnet do zero ou adicionar um portal/serviço.
---

# /dotnet-new — Scaffold de projeto .NET (clean | wafx)

$ARGUMENTS

---

## 🔴 Regras

1. **Carregue a skill `dotnet-project-scaffold` primeiro** — ela tem a estrutura, os passos e os pacotes de cada padrão. Este command é o gatilho; a skill é a fonte de verdade.
2. **Só versões LTS.** Nunca scaffolde em STS. `clean` → .NET 10 (LTS); `wafx` → .NET 8 (LTS). ORMs acompanham a major do framework. Se o usuário pedir explicitamente outra versão LTS, confirme.
3. **Pacotes mínimos.** Instale só o que o projeto usa — nunca EF + Dapper + Telerik "por padrão".
4. **Confirme antes de gerar em massa.** Mostre o plano (padrão, framework, projetos, pacotes) e gere após o OK. `dotnet build` no final.
5. **Spec-driven.** Após gerar, sugira registrar a escolha de padrão num `/adr` e a estrutura numa `/spec`.

---

## Parâmetros

```
/dotnet-new <nome> [--pattern clean|wafx] [--orm efcore|dapper|both] [--portal <nome>]
```

- `<nome>` — nome da solução/projeto (PascalCase). Vira o prefixo (`<Nome>.Api`, `<Nome>.WEB`, ...).
- `--pattern` — `clean` (default) ou `wafx`. Se ausente e ambíguo, **pergunte** antes de gerar.
- `--orm` — `efcore` (escritas), `dapper` (leituras), `both` (default no `clean`: EF write + Dapper read).
- `--portal` — só no `wafx`: cria um portal web adicional (`<Nome>.<Portal>.WEB`) referenciando as camadas de backend existentes.

---

## Passos

1. **Carregar a skill** `dotnet-project-scaffold` (via Skill) e seguir a seção do padrão escolhido.
2. **Resolver o padrão**
   - Flag `--pattern` fornecida → use-a.
   - Ausente → faça 1-2 perguntas (greenfield DDD/microserviço? → `clean`; encaixar em solução WAFX/MVC multi-portal? → `wafx`).
3. **Fixar versões LTS** — `clean`: net10.0; `wafx`: net8.0. Pacotes EF Core na mesma major.
4. **Montar o plano** e mostrar ao usuário: padrão, framework, lista de projetos, referências, pacotes. Aguardar OK.
5. **Gerar** com os comandos `dotnet new`/`dotnet sln add`/`dotnet add reference` da skill, na ordem certa (no `clean`, dependências apontam para dentro; Domain não referencia ninguém).
6. **Arquivos de borda** — `.editorconfig` (4 espaços, CRLF, `_camelCase`), `Directory.Build.props` (TargetFramework, Nullable=enable) no `clean`; `Program.cs`/`Startup.cs` conforme o padrão.
7. **`--portal`** (wafx) — pular criação de camadas; criar só o novo `.WEB` e referenciar BUSINESS/DATA/ENTITY/LANGUAGE.
8. **Validar** — `dotnet build`. Reportar o resultado real (não afirmar sucesso sem o build passar).

---

## Saída

```
[OK] Projeto <Nome> gerado — padrão <clean|wafx>, .NET <versão LTS>.

Estrutura:
  <árvore de projetos criada>

Build: <resultado do dotnet build>

Próximos passos:
- /adr registrar a escolha de arquitetura (<clean|wafx>)
- /spec descrever a primeira feature
- Implementar seguindo a skill dotnet-backend-standards + dotnet-orm-efcore/dapper
```

---

## Uso

```
/dotnet-new Financeiro.Api --pattern clean --orm both
/dotnet-new Cobranca --pattern clean
/dotnet-new NEWPORTAL --pattern wafx
/dotnet-new Relatorios --pattern wafx
```
