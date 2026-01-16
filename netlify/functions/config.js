exports.handler = async () => {
  const { SUPABASE_URL = "", SUPABASE_ANON_KEY = "" } = process.env;

  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      "Cache-Control": "no-store",
    },
    body: JSON.stringify({
      SUPABASE_URL,
      SUPABASE_ANON_KEY,
    }),
  };
};
