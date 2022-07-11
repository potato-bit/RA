import random
import datetime

class House:
    def __init__(self,id,rooms,status,bids):
        self.id = id
        self.rooms = rooms
        self.status = status
        self.bids = bids
    
    def __str__(self):
        return f"House ID:{self.id} has {self.rooms} rooms and {len(self.bids)} bid(s). It is currently {self.status}"

    def shortlist(self):
        top_priority = 5
        shortlist = []
        priority = []
        ap_dates = []
        bp_dates = []
        for x in self.bids:
            if applicants[x].priority < top_priority:
                priority.clear()
                top_priority = applicants[x].priority
                priority.append(x)
            elif applicants[x].priority == top_priority:
                priority.append(x)
            else:
                continue

        shortlist = priority
        if len(priority) > 1:
            early_date = datetime.date.today()
            for x in priority:
                if applicants[x].ap_date < early_date:
                    early_date = applicants[x].ap_date
                    ap_dates.append(x)
                elif applicants[x].ap_date == early_date:
                    ap_dates.append(x)
                else:
                    continue
            shortlist = ap_dates

        
        if len(ap_dates) > 1:
            early_date = datetime.date.today()
            for x in ap_dates:
                if applicants[x].bp_date < early_date:
                    early_date = applicants[x].bp_date
                    bp_dates.append(x)
                elif applicants[x].bp_date == early_date:
                    bp_dates.append(x)
                else:
                    continue
            shortlist = bp_dates

        return shortlist



class Applicant:
    def __init__(self,id,priority,bp_date,ap_date,hsize,status):
        self.id = id
        self.priority = priority
        self.bp_date = bp_date
        self.ap_date = ap_date
        self.hsize = hsize
        self.status = status

    def __str__(self):
        return f"Applicant {self.id} is in Priority Band {self.priority}. They have a need of {self.hsize} rooms and are currently {self.status}"
    
    def bidder(self,hlist):
        shortlist = []
        for x in hlist:
            if hlist[x].rooms == self.hsize:
                shortlist.append((x,hlist[x]))
        try:
            bids = random.sample(shortlist,k=3)
        except ValueError:
            bids = random.sample(shortlist,k=len(shortlist))
        for x in bids:
            houses[x[0]].bids.append(self.id)

        return bids



from faker import Faker


def date_generator(y,m,d):
    fake = Faker()
    start_date = datetime.datetime(y,m,d)
    return fake.date_between(start_date=start_date, end_date='now')

def house_generator(ind):
    id = ind
    rooms  = random.randint(0,5)
    house = House(id,rooms,'Live',[])
    return house

def applicant_generator(ind):
    id = ind
    priority = random.randint(1,4)
    bp_date = date_generator(2015,1,1)
    ap_date = date_generator(2021,9,19)
    hsize = random.randint(0,5)
    applicant = Applicant(id,priority,bp_date,ap_date,hsize,'Live')
    return applicant

houses = {}
for x in range(1,21):
    houses[x] = house_generator(x)
applicants = {}
for x in range(1,201):
    applicants[x] = applicant_generator(x)

for x in houses:
    print(houses[x])

for x in applicants:
    applicants[x].bidder(houses)

for x in houses:
    houses[x].shortlist()
