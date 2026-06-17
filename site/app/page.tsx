import { createClient } from '@/utils/supabase/server';
import { cookies } from 'next/headers';

export default async function Page() {
  const cookieStore = await cookies();
  const supabase = createClient(cookieStore);

  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data: contacts } = user
    ? await supabase.from('contacts').select('id, name').limit(10)
    : { data: null };

  return (
    <main>
      <h1>GiroCall</h1>
      <p>Spin the Giro. Make the Call. Stay Connected.</p>

      {user ? (
        <>
          <p>Signed in as {user.email}</p>
          <h2>Your people</h2>
          <ul>
            {contacts?.map((contact) => (
              <li key={contact.id}>{contact.name}</li>
            )) ?? <li>No contacts yet.</li>}
          </ul>
        </>
      ) : (
        <p>Sign in via the Flutter app to see your contacts here.</p>
      )}
    </main>
  );
}