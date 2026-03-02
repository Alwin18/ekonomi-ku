create table public.incomes (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid not null references auth.users(id) on delete cascade,

    amount numeric(15,2) not null check (amount > 0),
    description text,
    transaction_date date not null,

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);
create index idx_incomes_user_id on public.incomes(user_id);
create index idx_incomes_transaction_date on public.incomes(transaction_date);

create table public.expenses (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid not null references auth.users(id) on delete cascade,

    amount numeric(15,2) not null check (amount > 0),
    description text,
    transaction_date date not null,

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);
create index idx_expenses_user_id on public.expenses(user_id);
create index idx_expenses_transaction_date on public.expenses(transaction_date);

create table public.loans (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid not null references auth.users(id) on delete cascade,

    amount numeric(15,2) not null check (amount > 0),
    description text,

    status loan_status not null default 'active',
    due_date date,
    paid_at timestamptz,

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);
create index idx_loans_user_id on public.loans(user_id);
create index idx_loans_status on public.loans(status);
create index idx_loans_due_date on public.loans(due_date);