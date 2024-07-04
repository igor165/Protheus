Create procedure MAT033_##
( 
 @IN_FILIALCOR    char('B1_FILIAL'), 
 @OUT_RESULTADO   float output
)

as

/* -------------------------------------------------------------------
    Versão      -  <v> Protheus 12 </v>
    Descricao   -  Ponto de entrada na procedure MAT028
    Assinatura  -  <a> 001 </a>
    Entrada     -  @IN_FILIALCOR - Filial corrente                   

    Saida       -  @OUT_RESULTADO   - Resultado da procedure

    Responsavel :  Ricardo Gonçalves
    Data        :  26.07.2001
------------------------------------------------------------------- */
begin
  select @OUT_RESULTADO = '1'
end
