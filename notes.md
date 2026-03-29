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

now i have to call rpc function for SELECT * FROM public.get_some_imp_points('6f762715-4319-4392-a1b7-9c90817470f6'); and then create next tile to show the  received data in further format [
  {
    "included_numbers": [
      "2",
      "7"
    ],
    "description": "You have good six sense, ie knows what is going to happen."
  },
  {
    "included_numbers": [
      "3",
      "7"
    ],
    "description": "Your numbers are good for higher studies."
  },
  {
    "included_numbers": [
      "4",
      "8"
    ],
    "description": "You are having struggling number, make sure that total of your phone, vehicle and house number doesn’t come to 4 or 8."
  }
]

---------------------------------------------


now i have to call rpc function for SELECT public.get_stock_market_info('6f762715-4319-4392-a1b7-9c90817470f6'); and then create next tile to show the  received data in further format [
  {
    "get_stock_market_info": "You are good at analysing the stock, you can start your own advisory or consultancy"
  }
]


-------------------------------------------------


now i have to call rpc function for SELECT * FROM public.get_remedy_values('6f762715-4319-4392-a1b7-9c90817470f6'); and then create next tile to show the  received data in further format [
  {
    "unlucky_numbers": [
      6,
      8
    ],
    "unlucky_colors": [
      "White"
    ],
    "lucky_numbers": [
      7,
      1,
      3,
      5,
      4,
      2
    ],
    "lucky_colors": [
      "Green",
      "Red",
      "Yellow",
      "Blue",
      "Grey"
    ],
    "lucky_days": [
      "Monday",
      "Thursday"
    ],
    "numbers_for_remedy": [
      5
    ],
    "numbers_not_for_remedy": [
      6
    ]
  }
]


----------------------------------------------------

protect static tables on supabase