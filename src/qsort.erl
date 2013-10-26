-module(qsort).                                                                    
-compile(export_all).                                                              
                                                                                   
qsort([]) -> [];                                                                   
qsort([Pivot]) -> [Pivot];                                                         
qsort([Pivot | Rest]) ->                                                           
    L = [X || X <- Rest, X =< Pivot],                                              
    R = [X || X <- Rest, X > Pivot],                                               
    [SortL, SortR] = mprd_master:map(fun qsort/1, [L, R], false),                  
    SortL ++ [Pivot] ++ SortR.