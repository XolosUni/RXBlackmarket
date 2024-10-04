dealer = {}
rx = {}

dealer.method = 'cash'
dealer.Ped = {
    model = 'u_m_m_jewelsec_01',
    coords = vec4(-468.51, 6289.7, 13.61, 160),  
    animDict = 'anim@amb@warehouse@laptop@',
    animName = 'idle_a'  
}
 
dealer.items = {
    {itemName = 'laptop',    price = 1, minRep = 0},
    {itemName = 'ilegalusb', price = 1, minRep = 0},
    {itemName = 'tabletvpn', price = 1, minRep = 0}
}

dealer.BlacklistJobs = {
    'police',
    'lawyer',
    'ambulance',
}


-- RX

rx.CollectPed = {
    model = 'u_m_y_smugmech_01',
    coords = vec4(-471.66, 6291.37, 13.61, 145.48),
    animDict = 'missfam4',
    animName = 'base'
}

rx.ReqToRun = {
    'ilegalusb',
    'tabletvpn'
}

rx.DeliveryTime = 1 -- in MS


rx.DefaultRep = '3'


rx.customPriority = {
  FPW73802 = 100,
--  CitizenID = 7,
}

rx.PriorityItem = {
--  ['itemName'] = "priority"
}