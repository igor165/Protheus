create procedure SOMADT_##
( @IN_DATA char(08),
  @IN_DIAS integer,
  @OUT_DATA char(08) output
)
as
/* ---------------------------------------------------------------------------------------------------------------------
    Versão      - <v> Protheus 9.12 </v>
    Programa    -  Somadata
    Assinatura  -  <a> 001 </a>
    Descricao   -  <d> soma n dias a uma data. (AAAAMMDD) </d>
    Entrada     -  <ri> @IN_DATA       - Data atual
                   @IN_DIAS       - Numero de dias a somar </ri>
                   
    Saida       -  <ro> @OUT_DATA      - Data com os dias somados </ro>

    Responsavel :  <r> Ricardo Gonçalves </r>
    Data        :  <dt> 18.10.2001 </dt>
--------------------------------------------------------------------------------------------------------------------- */
begin
   select @OUT_DATA = '19000101'
   if (@IN_DATA is not null) and (@IN_DATA <> ' ') and (@IN_DIAS is not null) begin
      select @OUT_DATA = @IN_DATA   
      select @OUT_DATA = Convert( char(08), Convert( datetime, @IN_DATA, 112 ) + @IN_DIAS, 112 )
   end
end