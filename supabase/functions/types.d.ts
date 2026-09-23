declare module 'https://esm.sh/@supabase/supabase-js@2' {
  export function createClient(url: string, key: string): SupabaseClient;

  interface SupabaseClient {
    from(table: string): SupabaseQuery;
  }

  interface SupabaseQuery {
    select(columns?: string): SupabaseQuery;
    eq(column: string, value: unknown): SupabaseQuery;
    not(column: string, operator: string, value: unknown): SupabaseQuery;
    maybeSingle<T = Record<string, unknown>>(): Promise<{
      data: T | null;
      error: { message: string } | null;
    }>;
    then<TResult1 = unknown, TResult2 = never>(
      onfulfilled?: ((value: {
        data: Array<Record<string, unknown>> | null;
        error: { message: string } | null;
      }) => TResult1 | PromiseLike<TResult1>) | null,
      onrejected?: ((reason: unknown) => TResult2 | PromiseLike<TResult2>) | null,
    ): Promise<TResult1 | TResult2>;
  }
}

declare const Deno: {
  env: {
    get(name: string): string | undefined;
  };
  serve(handler: (request: Request) => Response | Promise<Response>): void;
};
