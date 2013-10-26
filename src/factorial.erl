-module(factorial).                                                                
-export([my_map/1, my_reduce/1]).                                                  
                                                                                   
fact(0) -> 1;                                                                      
                                                                                   
fact(N) when N < 0 -> io:format("参数错误~n");                                     
                                                                                   
fact(N) when N > 0 -> N * fact(N - 1).                                             
                                                                                   
% used at all nodes                                                                
my_map(InDat) ->                                                                   
    fact(InDat).                                                                   
                                                                                   
% used only at master side                                                         
my_reduce([]) ->                                                                   
    [];                                                                            
                                                                                   
my_reduce(OutDat) ->                                                               
    io:format("my reduce come in~n", []),                                          
    io:format("~w~n", [OutDat]).                  