# Contexto — Padrões de UI

> Padrões de UI reutilizáveis do projeto. Carregado **sob demanda** pelo `CLAUDE.md` (import `@`).

## Paginação

- Server-side obrigatória: `.range(from, to)` + `count: 'exact'`; page size padrão **20**.

## Toast / notificações

- `<componente e quando usar success/error/info>`

## Combobox / Select

- `<componente do design system; busca/async>`

## DatePicker

- `<componente do design system>` — **nunca** usar `<input type="date">` nativo.

## ConfirmDialog

- Toda exclusão exige confirmação via modal — **nunca** `confirm()` nativo.

## Loading states

- `NavProgress` (topo) · `loading.tsx` por rota · `isPending` nos botões.

## Features / permissões

- `<como registrar features (code_read / code_write / code_delete) se o projeto usa permissões>`
