// Edge Function "bright-function" — cole no Supabase (Edge Functions → Deploy a new function).
// Só aceita chamadas de um login com role = 'admin' e ativo. Registra tudo em `logs`.
import { createClient } from "npm:@supabase/supabase-js@2";

const DOMINIO = "seuapp.com";
const PAPEIS = ["usuario", "agente", "gestao", "admin"];
const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const resp = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  try {
    const admin = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, {
      auth: { persistSession: false },
    });
    const token = (req.headers.get("Authorization") ?? "").replace("Bearer ", "");
    const { data: quem, error: errQuem } = await admin.auth.getUser(token);
    if (errQuem || !quem.user) return resp({ error: "Sessão inválida. Entre novamente." }, 401);
    const eu = quem.user;

    const { data: meuPerfil } = await admin.from("profiles").select("role, ativo").eq("id", eu.id).maybeSingle();
    if (!meuPerfil || meuPerfil.role !== "admin" || !meuPerfil.ativo) {
      return resp({ error: "Apenas o administrador pode fazer isso." }, 403);
    }

    const b = await req.json();
    const log = (acao: string, detalhe: string) =>
      admin.from("logs").insert({ usuario_id: eu.id, acao, detalhe });

    if (b.acao === "criar") {
      const usuario = String(b.usuario ?? "").trim().toLowerCase();
      if (!/^[a-z0-9._-]{3,30}$/.test(usuario)) return resp({ error: "Usuário inválido." }, 400);
      if (!PAPEIS.includes(b.perfil)) return resp({ error: "Perfil inválido." }, 400);
      if (!b.senha || String(b.senha).length < 6) return resp({ error: "Senha muito curta." }, 400);
      const { data, error } = await admin.auth.admin.createUser({
        email: `${usuario}@${DOMINIO}`,
        password: b.senha,
        email_confirm: true,
        user_metadata: { trocar_senha: false },
      });
      if (error || !data.user) {
        const msg = error?.message?.includes("already") ? "Esse usuário já existe." : error?.message;
        return resp({ error: msg ?? "Erro ao criar login." }, 400);
      }
      const { error: errPerfil } = await admin.from("profiles").upsert({
        id: data.user.id, nome: b.nome, usuario, role: b.perfil, agente_id: b.agente_id ?? null, ativo: true,
      }, { onConflict: "id" });
      if (errPerfil) {
        await admin.auth.admin.deleteUser(data.user.id);
        return resp({ error: errPerfil.message }, 400);
      }
      await log("criar_login", `@${usuario} (${b.perfil})`);
      return resp({ ok: true, id: data.user.id });
    }

    if (b.acao === "editar") {
      if (!PAPEIS.includes(b.perfil)) return resp({ error: "Perfil inválido." }, 400);
      if (b.id === eu.id && (b.perfil !== "admin" || b.ativo === false)) {
        return resp({ error: "Você não pode remover o seu próprio acesso de admin." }, 400);
      }
      const { error } = await admin.from("profiles")
        .update({ nome: b.nome, role: b.perfil, agente_id: b.agente_id ?? null, ativo: b.ativo !== false })
        .eq("id", b.id);
      if (error) return resp({ error: error.message }, 400);
      await admin.auth.admin.updateUserById(b.id, { ban_duration: b.ativo === false ? "876000h" : "none" });
      await log("editar_login", `${b.nome} → ${b.perfil}${b.ativo === false ? " (desativado)" : ""}`);
      return resp({ ok: true });
    }

    if (b.acao === "senha") {
      if (!b.senha || String(b.senha).length < 6) return resp({ error: "Senha muito curta." }, 400);
      const { error } = await admin.auth.admin.updateUserById(b.id, {
        password: b.senha, user_metadata: { trocar_senha: false },
      });
      if (error) return resp({ error: error.message }, 400);
      await log("trocar_senha", `login ${b.id}`);
      return resp({ ok: true });
    }

    if (b.acao === "excluir") {
      if (b.id === eu.id) return resp({ error: "Você não pode excluir o seu próprio login." }, 400);
      const { data: alvo } = await admin.from("profiles").select("usuario").eq("id", b.id).maybeSingle();
      await admin.from("profiles").update({ agente_id: null }).eq("agente_id", b.id);
      await admin.from("profiles").delete().eq("id", b.id);
      const { error } = await admin.auth.admin.deleteUser(b.id);
      if (error) return resp({ error: error.message }, 400);
      await log("excluir_login", `@${alvo?.usuario ?? b.id}`);
      return resp({ ok: true });
    }

    return resp({ error: "Ação desconhecida." }, 400);
  } catch (e) {
    return resp({ error: String(e) }, 500);
  }
});
