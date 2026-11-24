# Gestão ACS Saúde

## Overview
App de saúde pública para um posto/hospital que conecta moradores, agentes de saúde, gestão e o administrador. A primeira tela é só o login (usuário e senha); o perfil gravado no servidor decide para qual área a pessoa vai.

## Built vs Coming Soon
- Built: login por usuário + troca obrigatória de senha, roteamento por perfil (usuario/agente/gestao/admin)
- Built: propagandas (imagem/vídeo) e campanhas em texto para todos os logins, visualizador estilo stories com avanço por toque
- Built: agente envia solicitações (consulta, reclamação, outro) e vê reuniões/avisos da gestão
- Built: gestão aceita (com data/hora) ou recusa (com motivo) e publica reuniões, avisos e campanhas
- Built: admin cria/edita/desativa/exclui logins, troca senhas, publica/pausa/exclui propagandas e vê os registros
- Depende do backend: rodar `supabase/setup.sql` e publicar a Edge Function (código em `supabase/functions/admin-usuarios/index.ts`, publicada no Supabase como `bright-function`)
- Built: área do agente com painel, famílias, pessoas (doenças), vacinas (catálogo, agendar, concluir com quem aplicou/dia/lote, excluir), visitas (agendar, concluir com questionário, justificar, sem exclusão) e relatório mensal em PDF só de meses fechados
- Built: tema escuro/claro para todos os perfis, salvo no aparelho
- Built: Configurações › "Cores e letras" (4 perfis): 5 fontes, cores fixas ou degradê e paleta; salvo no aparelho e aplicado via `AppTheme.build` em main.dart (o degradê vira brandStart/brandEnd; em cores fixas os dois são iguais)
- Built: aba "Avisos" do agente abre com quadro de avisos da gestão (letra grande) e quadro de atrasos (visitas, vacinas, cadastros incompletos, calculado no app); aba "Status" com stories grandes para agente e usuário
- Depende do backend: rodar também `supabase/agentes.sql` (tabelas acs_*) para a área do agente
- Built: aba "Consultas" (depois de Status) para usuário e agente; a gestão aceita (data/hora) ou cancela (motivo) na própria aba Consultas
- Built: backup com senha em Configurações para os 4 perfis (engrenagem no topo; no agente, em Perfil)
- Depende do backend: rodar `supabase/consultas.sql` (tabela acs_consultas e função acs_agentes)
- Built: cada login é uma pessoa; envios para a gestão vão para UM login, achado pelo usuário exato (função `acs_buscar_login`); usuário errado = erro e nada é enviado
- Built: agente envia PDF à gestão (Perfil › Documentos); gestão tem aba "Docs"; consultas do morador vão para a agente definida pelo admin, que encaminha/reencaminha a um login da gestão; tudo mostra Enviado/Recebido/Visto
- Built: Configurações (4 perfis) com contato do admin (só admin edita), versão do app (gestão/admin publicam APK; aviso grande em todos os perfis quando há versão maior que a instalada) e permissões (internet, notificações, arquivos)
- Built: Status estilo WhatsApp para gestão/agente/usuário, com vistos por login; a gestão publica imagem/vídeo na aba Status
- Depende do backend: rodar `supabase/comunicacao.sql` (3º script)
- Built: aba "Saúde" do morador com carteira de vacinação da família, histórico de visitas (cancelar com justificativa) e contato do agente; o agente vincula a família ao login (ícone de link na família) e edita o contato em Perfil
- Depende do backend: rodar `supabase/morador.sql` (4º script). O cancelamento pelo morador vira status `nao_realizada` com `cancelada_pelo_morador`, por isso já entra no relatório mensal sem mudar o enum
- Ainda não feito (próximas etapas): pedidos de alteração de dados, Minhas solicitações, mensagens ao agente, WhatsApp com mensagem padrão, lembretes de vacina, envio de fotos/documentos do morador, relato de sintomas, Minha família, documentos para baixar
- Ainda não feito: notificação push (avisos aparecem dentro do app), agenda detalhada, mensagens de texto livres entre logins

## Tech Stack & Key Decisions
- Supabase (plano grátis), o servidor escolhido pelo usuário; o app usa só a chave publicável (`lib/config/supabase_config.dart`)
- O login por nome de usuário vira o e-mail interno `usuario@seuapp.com`; as senhas ficam só no Supabase Auth (bcrypt)
- Não há troca obrigatória de senha: só o admin muda a própria senha (opcional, rota /trocar-senha); os demais perfis não alteram nada do login. Trocar senha/nome pelo admin não desconecta; só a exclusão (ou desativação) tira a pessoa
- A gestão de contas passa pela Edge Function `bright-function` (o nome é definido em `SupabaseConfig.adminFunction`), que confere role=admin no servidor; o app nunca contém a service_role
- Dados que não precisam circular ficam em shared_preferences (último usuário)
- Provider + GoRouter com providers por rota; o redirect impede que um perfil abra a área de outro

## Architecture
- UI → providers (SafeNotifier) → repositories (Supabase) → models; não há camada de services, porque as regras ficam no servidor (RLS e Edge Function)
- `solicitacoes.especialidade` guarda "Tipo · Assunto" (Consulta/Reclamação/Outro), porque a tabela não tem coluna de tipo
- O agente é o solicitante (usuario_id = agente_id = ele); o usuário comum só vê o mural
- A tabela `reunioes` guarda reuniões e avisos aos agentes (coluna `tipo`); as campanhas viram stories sem mídia, visíveis a todos
- As propagandas com mídia vão para o bucket público `propagandas`, e a URL pública é salva em `stories.midia_url`
- Todo erro do servidor aparece na tela (ErrorBanner/SnackBar) com a mensagem real
- A área do agente usa tabelas novas `acs_*` (as antigas `vacinas`/`visitas` ficaram intactas por terem colunas desconhecidas); o RLS deixa cada agente ver só os próprios dados e não existe regra de exclusão de visitas, nem de edição depois de concluída/justificada
- As vacinas do catálogo valem para todas as pessoas por cruzamento no app (catálogo × pessoas); só existe registro quando agenda ou conclui. O PDF usa `pdf` + `printing` (único pacote com compartilhar/baixar em web, Android e iOS), gerado em `services/relatorio_visitas_service.dart`
- As rotas internas do agente ficam sob um ShellRoute com os providers, para que famílias, vacinas e visitas sejam compartilhados entre abas e telas internas; bottom sheets recebem callbacks porque abrem acima do ShellRoute

- Consultas: o usuário só pode pedir para a agente de `profiles.agente_id` (conferido no app e no RLS); o agente só pede para pessoas de acs_membros dele. A lista de agentes vem da função `acs_agentes()` (security definer), porque o RLS de profiles esconde os agentes do usuário
- Backup: arquivo `.acsbackup` em JSON com AES-256-GCM e chave PBKDF2 da senha (`services/backup_cripto.dart`, pacote cryptography); salvo/lido com file_picker. Usar o backup só recria no servidor o que falta (por id e chaves únicas), respeitando o RLS: visitas só agendadas e consultas só solicitadas; o backup só vale para o mesmo login

- Enviado/Recebido/Visto: colunas *_recebido_em/*_visto_em; "recebido" é gravado quando o destinatário carrega a lista, "visto" quando toca no item. Excluir um login da gestão zera `acs_consultas.gestor_id` (on delete set null) e a consulta volta para a agente
- `AppInfoProvider` fica em main.dart (global) porque versão e contato do admin valem para todos os perfis; a versão instalada vem do package_info_plus, então cada APK novo precisa de número de versão maior

## Conventions
- Uma tela nova entra como rota em `lib/router/app_router.dart`, com os providers dela; a rota precisa começar pelo prefixo do perfil (/admin, /gestao…)
- Os formulários são bottom sheets que recebem um callback `Future<String?>` (null = sucesso, texto = erro mostrado)
- Os textos do app ficam em português, com datas em pt_BR via `widgets/common/formatos.dart`

## Key Patterns & Gotchas
- O RLS de `profiles` não permite insert/update pelo cliente, de propósito: ninguém consegue se promover a admin
- Para desativar um login, a função também aplica um ban no Auth; sem isso, uma sessão já aberta continuaria entrando
- Se o upload da propaganda dá certo mas o insert falha, o arquivo enviado é removido

## Design System
- Verde-saúde institucional com acento laranja; a fonte Nunito deixa o app acolhedor e legível
- Os cabeçalhos usam gradiente verde da marca; os stories ficam sobre fundo quase preto
- Espaçamento em ritmo de 8 (tokens AppTheme.spacing*), cantos arredondados de 10, 16 e 24
