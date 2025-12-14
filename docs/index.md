# Dedalus Docs

> Homepage

export const Hero = () => {
  return <div className="flex flex-col items-center justify-center text-center px-4 pt-32 pb-16">
      <h1 className="text-6xl font-bold mb-4 tracking-tight">
        Build with Dedalus
      </h1>
      <p className="text-sm font-medium text-zinc-500 dark:text-zinc-500 mb-6 tracking-wide uppercase">
        Dedalus Labs is the AI cloud for agents
      </p>
      <p className="text-lg text-zinc-600 dark:text-zinc-400 max-w-2xl leading-relaxed">
        Build and deploy MCP servers and let our Agents SDK orchestrate complex logic with any model from any provider.
      </p>
    </div>;
};


export const FeatureCard = ({icon, title, description, href}) => {
  return <a href={href} className="flex flex-col p-8 rounded-2xl border border-zinc-200 dark:border-zinc-800 hover:border-zinc-300 dark:hover:border-zinc-700 transition-colors group max-w-md mx-auto">
      <div className="text-3xl mb-4">{icon}</div>
      <h3 className="text-xl font-semibold mb-2 group-hover:text-primary transition-colors">
        {title}
      </h3>
      <p className="text-sm text-zinc-600 dark:text-zinc-400">
        {description}
      </p>
    </a>;
};


<Hero />

<div className="max-w-6xl mx-auto px-4 pb-32">
  <FeatureCard icon="▶" title="Get started with the SDK" description="Install the Python and TypeScript SDK and make your first API call in minutes." href="/sdk/quickstart" />
</div>


---

> To find navigation and other pages in this documentation, fetch the llms.txt file at: https://docs.dedaluslabs.ai/llms.txt