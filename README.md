# Astro Starter Kit: Minimal

```sh
npm create astro@latest -- --template minimal
```

> 🧑‍🚀 **Seasoned astronaut?** Delete this file. Have fun!

## 🚀 Project Structure

Inside of your Astro project, you'll see the following folders and files:

```text
/
├── public/
├── src/
│   └── pages/
│       └── index.astro
└── package.json
```

Astro looks for `.astro` or `.md` files in the `src/pages/` directory. Each page is exposed as a route based on its file name.

There's nothing special about `src/components/`, but that's where we like to put any Astro/React/Vue/Svelte/Preact components.

Any static assets, like images, can be placed in the `public/` directory.

## 🧞 Commands

All commands are run from the root of the project, from a terminal:

| Command                   | Action                                           |
| :------------------------ | :----------------------------------------------- |
| `npm install`             | Installs dependencies                            |
| `npm run dev`             | Starts local dev server at `localhost:4321`      |
| `npm run build`           | Build your production site to `./dist/`          |
| `npm run preview`         | Preview your build locally, before deploying     |
| `npm run astro ...`       | Run CLI commands like `astro add`, `astro check` |
| `npm run astro -- --help` | Get help using the Astro CLI                     |

## Gestão de usuários administrativos

O administrador principal pode convidar, criar diretamente com senha, desativar, reativar e excluir
usuários pela seção **Usuários administrativos** do painel. As operações usam a Edge Function
`admin-users`, mantendo a chave `SUPABASE_SERVICE_ROLE_KEY` somente no ambiente do Supabase.
Convites novos levam o usuário ao `/admin`, onde ele precisa definir uma senha antes de
acessar o catálogo administrativo. As senhas exigem pelo menos 8 caracteres, uma letra
maiúscula, um número e um caractere especial.

Essa configuração deve ser repetida no projeto Supabase de produção antes da publicação:
publicar a Edge Function, cadastrar seus secrets e adicionar o domínio de produção às
Redirect URLs do Auth.

Publique a função antes de usar esses controles:

```sh
supabase functions deploy admin-users
```

Configure `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` e `APP_URL` como
secrets da Edge Function. Use `APP_URL=http://localhost:4321` no desenvolvimento e
`APP_URL=https://artbrasilpresentes.com.br` em produção. A URL correspondente também deve
estar cadastrada nas Redirect URLs do Supabase Auth. Desativar um usuário preserva sua conta
no Auth; excluir remove definitivamente a conta e o perfil administrativo.

## 👀 Want to learn more?

Feel free to check [our documentation](https://docs.astro.build) or jump into our [Discord server](https://astro.build/chat).
