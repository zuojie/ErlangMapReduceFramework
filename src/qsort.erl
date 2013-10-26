-module(qsort).                                                                    
-compile(export_all).                                                              
                                                                                   
my_reduce([]) ->                                                                   
    [];                                                                            
                                                                                   
my_reduce(OutDat) ->                                                               
    OutDat.                                                                        
                                                                                   
qsort([]) -> [];                                                                   
qsort([Pivot]) -> [Pivot];                                                         
qsort([Pivot | Rest]) ->                                                           
    L = [X || X <- Rest, X =< Pivot],                                              
    R = [X || X <- Rest, X > Pivot],                                               
    [SortL, SortR] = mprd_master:start(fun qsort/1, fun my_reduce/1, [L, R]),   
    SortL ++ [Pivot] ++ SortR.                         
