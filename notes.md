now i have to call rpc function for SELECT * FROM public.get_remedies_for_birthdate('6f762715-4319-4392-a1b7-9c90817470f6'); and then create next tile to show the  received data in further format [
  {
    "missing_number": 5,
    "description": "Keep money plant in house, green colour bracelet in left hand or green pen/handkerchief in pocket, or place crystal ball either white or yellow, or hang yellow bulb in center of house."
  }
]

now i have to call rpc function for SELECT * FROM public.get_numbers_not_for_remedy('6f762715-4319-4392-a1b7-9c90817470f6'); and then create next tile to show the  received data in further format [
  {
    "get_numbers_not_for_remedy": [
      6
    ]
  }
]

consider this html code and create above tiles  to show the received data:
<div class="p-2 m-2 mb-3 shadow">
          <h3>Missing number Remedies</h3>
          <hr class="m-1 bg-primary">
          <div *ngFor="let eachItem of arrayOfNumbersForRemedy">
            <p>
              <b>Remedy for number {{eachItem}}</b><br>
              {{remediesOfMissingNumbers[eachItem].description}}
            </p>
          </div>
          <p *ngIf="arrayOfNumbersNotForRemedy.length" class="fst-italic">
            No remedy to number {{arrayOfNumbersNotForRemedy | appendSpaceToEachItem}} as
            <span *ngIf="arrayOfNumbersNotForRemedy.length === 1">this is</span>
            <span *ngIf="arrayOfNumbersNotForRemedy.length > 1">they are </span>
            enemy to you
          </p>
          <p>[Multiple remedies are given for each number, do any 1 remedy for 1 number as per
            your convenience]</p>
        </div>


---------------------------------------------------





----------------------------------------------------

protect static tables on supabase