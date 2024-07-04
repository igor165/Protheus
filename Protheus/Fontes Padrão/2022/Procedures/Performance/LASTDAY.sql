Create procedure LASTDAY_##(
   @IN_DATA  Char( 08 ),
   @OUT_DATA Char( 08 ) OutPut 
   )
as
/* -------------------------------------------------------------------
    Versão      -  <v> Genérica </v>
    Assinatura  -  <a> 001 </a>
    Descricao   -  <d> Retorna o ultimo dia do mês </d>
      
    Entrada     -  <ri> @IN_DATA         - Data qualquer </ri>

    Saida       -  <ro> @OUT_DATA        - Retorno - Ultimo dia da data qualquer  </ro>
                   <o>  </o>

    Responsavel :  <r> Alice Y Yamamoto </r>
    Data        :  <dt> 14/05/10 </dt>
------------------------------------------------------------------- */

Declare @cData    VarChar( 08 )
Declare @iAno     Float
Declare @iResto   Float
Declare @iPos     Integer
Declare @cResto   VarChar( 10 )

begin
   Select @OUT_DATA = ' '
   Select @cData  = Substring( @IN_DATA, 5, 2 )   -- MES
   select @iAno   = 0
   select @iResto = 0
   Select @iPos   = 0
   select @cResto = ''
   
   /* --------------------------------------------------------------
      Ultimo dia do periodo para atualizacao do AKS
      -------------------------------------------------------------- */
   If @cData IN ( '01', '03', '05', '07', '08','10','12' ) begin
      select @cData = Substring( @IN_DATA, 1, 6 )||'31'
   end else begin
      If @cData = '02' begin
         Select @iAno = Convert( float, Substring(@IN_DATA, 1,4) )
         Select @iResto = @iAno/4
         Select @cResto = Convert( varchar( 10 ), @iResto )
         /* --------------------------------------------------------------
            nao existe '.' no @cResto , o nro é inteiro, divisivel por 4
            O ano deve ser múltiplo de 100, ou seja, divisível por 400
            -------------------------------------------------------------- */
         Select @iPos   = Charindex( '.', @cResto )
         If @iPos = 0 begin
            select @cData = Substring( @IN_DATA, 1, 6 )||'29'
            If @iAno in ( 2100, 2200, 2300, 2500 ) begin   -- ANOS NAO DIVISÍVEIS POR 400
               select @cData = Substring( @IN_DATA, 1, 6 )||'28'
            End
         end else begin
            select @cData = Substring( @IN_DATA, 1, 6 )||'28'
         end
      end else begin
         select @cData = Substring( @IN_DATA, 1, 6 )||'30'
      End
   End
   Select @OUT_DATA = @cData
End
