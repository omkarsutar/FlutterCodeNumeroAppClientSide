now i have to call rpc function for SELECT * 
FROM public.get_missing_number_tells('954814f7-e564-4b27-b9ee-e229dbd89e6e'); and then create next tile to show the  received data in further format [
  {
    "missing_number": 2,
    "description": "You have"
  },
  {
    "missing_number": 3,
    "description": "You have"
  },
  {
    "missing_number": 4,
    "description": "You lack"
  },
  {
    "missing_number": 5,
    "description": "You "
  }
]


------------------------------------------------

i have below table, i want to fetch data from this table and show carousel on birthdate analysis page

create table public.static_testimonials (
  id serial not null,
  person_name text not null,
  description text not null,
  image text not null,
  is_active boolean not null default true,
  constraint static_testimonials_pkey primary key (id)
) TABLESPACE pg_default;


---------------------------------------------------

