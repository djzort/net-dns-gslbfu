{

foo => [

{ Check =>  ['Sleep',6],
Action => ['Echo', 'This will never show up'], },
{ Check =>  ['Replay',0],
Action => ['Echo', 'This will never show up'], },
{ Check => 'LastResort',
Action => ['Echo', 'If I die, tell my wife hello'], },

],

}
