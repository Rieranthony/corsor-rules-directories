export const cossistantRules = [
  {
    tags: ["Cossistant", "Next.js", "Support Widget"],
    title: "Cossistant Cursor Rules",
    slug: "cossistant-cursor-rules",
    libs: ["@cossistant/next", "@cossistant/react"],
    content: `
# Cossistant Development Guidelines

## Support Widget Setup
1. Install the official packages:
   \`\`\`bash
   npm install @cossistant/next @cossistant/react
   \`\`\`
2. Expose your public key through \`NEXT_PUBLIC_COSSISTANT_API_KEY\`.
3. Wrap the app layout with \`SupportProvider\` so every route can access widget context:
   \`\`\`tsx
   import { SupportProvider } from "@cossistant/next";

   export default function RootLayout({ children }: { children: React.ReactNode }) {
     return (
       <html lang="en">
         <body>
           <SupportProvider>{children}</SupportProvider>
         </body>
       </html>
     );
   }
   \`\`\`
4. Import styling based on your stack:
   - Tailwind v4: \`@import "@cossistant/react/tailwind.css";\`
   - Plain CSS / Tailwind v3: \`import "@cossistant/next/support.css";\`
5. Drop the \`<Support />\` widget anywhere in your UI to finish the baseline integration.

## Contextual Support Experiences
- Use \`<SupportConfig />\` per route to tailor quick options or welcome copy so users get contextual answers.
- Register extra routes with \`<Page />\` children when you need fully custom screens inside the widget.
- Respect the headless architecture: prefer composition over forks and keep landing-page fakes in sync with the real widget structure.

## Visitor Identity & Metadata
- Visitors start anonymous; call \`<IdentifySupportVisitor />\` (server) or \`useVisitor().identify()\` (client) once you have Better Auth / session data.
- Always pass stable \`externalId\` and email plus any useful \`metadata\` (plan, signup date, etc.) so agents see rich context.
- Update metadata after user actions with \`setVisitorMetadata\` to keep contacts fresh for every future conversation.

## Hooks & Programmatic Control
- \`useSupport()\` exposes \`isOpen\`, \`toggle\`, unread counts, available agents, and the low-level \`CossistantClient\`:
  \`\`\`tsx
  "use client";
  import { useSupport } from "@cossistant/next";

  export function CustomSupportButton() {
    const { isOpen, toggle, unreadCount } = useSupport();

    return (
      <button type="button" onClick={toggle} className="relative rounded-lg bg-primary px-4 py-2 text-white">
        {isOpen ? "Close support" : "Open support"}
        {unreadCount > 0 && (
          <span className="absolute -right-1 -top-1 flex h-5 w-5 items-center justify-center rounded-full bg-red-500 text-xs">
            {unreadCount}
          </span>
        )}
      </button>
    );
  }
  \`\`\`
- \`useVisitor()\` handles identification lifecycle and metadata updates; guard calls so you never re-identify contacts unnecessarily:
  \`\`\`tsx
  "use client";
  import { useEffect } from "react";
  import { useVisitor } from "@cossistant/next";

  export function AuthHandler({ user }: { user: { id: string; email: string; name?: string; image?: string } | null }) {
    const { visitor, identify, setVisitorMetadata } = useVisitor();

    useEffect(() => {
      if (user && !visitor?.contact) {
        identify({
          externalId: user.id,
          email: user.email,
          name: user.name,
          image: user.image,
        });
      }
    }, [user, visitor?.contact, identify]);

    const handleUpgrade = async () => {
      // ...perform billing logic...
      await setVisitorMetadata({ plan: "pro", upgradedAt: new Date().toISOString(), mrr: 99 });
    };

    return <button type="button" onClick={handleUpgrade}>Upgrade plan</button>;
  }
  \`\`\`

## API, Content, and QA Standards
- Keep \`<Support />\` props declarative: use \`quickOptions\`, \`defaultMessages\`, \`classNames\`, \`slots\`, and positioning props instead of ad-hoc DOM tweaks.
- Route-sensitive copy should live in \`SupportConfig\` or \`content\` overrides so translators and AI agents can localize easily.
- Never bypass built-in validation—use the provided hooks/components so visitor/contact state stays consistent with the backend.
- Test with Bun (\`bun run test\`, targeted \`turbo run test --filter @cossistant/react\`) and lint/format via \`bun run fix\` before submitting changes.
- Maintain accessibility: semantic headings, focus management, reduced motion respect, descriptive alt text, and no custom roles on interactive elements.
- Distribute documentation updates alongside rule files (e.g., AGENTS.md, llms.txt) to keep AI surfaces synchronized.
`,
    author: {
      name: "Cossistant Team",
      url: "https://cossistant.com",
      avatar: "https://cossistant.com/favicon.ico",
    },
  },
];
