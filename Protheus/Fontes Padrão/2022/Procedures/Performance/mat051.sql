Create Procedure MAT051_##
( 
 @IN_FILIALCOR    char('B1_FILIAL'),
 @IN_CODIGO       char('B1_COD'),
 @IN_MV_CUSFIL    char(01),
 @IN_MV_MOEDACM   char(05),
 @OUT_VLR1        float OutPut,
 @OUT_VLR2        float OutPut,
 @OUT_VLR3        float OutPut,
 @OUT_VLR4        float OutPut,
 @OUT_VLR5        float OutPut
)
as
/* ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Programa    -  <s> PegaCMUnif </s>
    Descricao   -  <d> Retorna os saldos unificados </d>
    Assinatura  -  <a> 001 </a>
    Entrada     -  <ri> @IN_FILIALCOR - Filial corrente
                        @IN_CODIGO    - Codigo do produto </ri>
    Saida       -  <ro> @OUT_VLR1      - Valor total moeda 1
                        @OUT_VLR2      - Valor total moeda 2
                        @OUT_VLR3      - Valor total moeda 3
                        @OUT_VLR4      - Valor total moeda 4
                        @OUT_VLR5      - Valor total moeda 5 </ro>
    Responsavel :  <r> Marcelo Pimentel </r>
    Data        :  <dt> 19.11.2007 </dt>
--------------------------------------------------------------------------------------------------------------------- */
Declare @cFil_SB2       Char('B2_FILIAL')
Declare @cAux           Varchar(3)
Declare @vVLR1          Float
Declare @vVLR2          Float
Declare @vVLR3          Float
Declare @vVLR4          Float
Declare @vVLR5          Float
Declare @vQTD           Float
Declare @iPos           Integer
Declare @nD5_QUANT     decimal( 'D5_QUANT' )

Begin
   select @cAux = 'SB2'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB2 OutPut

   select @vVLR1 = 0
   select @vVLR2 = 0
   select @vVLR3 = 0
   select @vVLR4 = 0
   select @vVLR5 = 0
   select @vQTD  = 0

   if @IN_MV_CUSFIL = '1' begin
      select @vVLR1 = Sum( B2_VATU1 ), 
             @vQTD  = Sum( B2_QATU )
        from SB2### (NoLock) 
       where B2_FILIAL = @cFil_SB2
         and B2_COD = @IN_CODIGO
         and D_E_L_E_T_ = ' '
       group by B2_FILIAL,B2_COD

      select @iPos = Charindex( '2', @IN_MV_MOEDACM )
      If @iPos > 0 begin    --Moeda 2
         select @vVLR2 = Sum( B2_VATU2 )
           from SB2### (NoLock) 
          where B2_FILIAL = @cFil_SB2
            and B2_COD = @IN_CODIGO
            and D_E_L_E_T_ = ' '
          group by B2_FILIAL,B2_COD
      End
      If @iPos > 0 begin    --Moeda 3
         select @vVLR3 = Sum( B2_VATU3 )
           from SB2### (NoLock) 
          where B2_FILIAL = @cFil_SB2
            and B2_COD = @IN_CODIGO
            and D_E_L_E_T_ = ' '
          group by B2_FILIAL,B2_COD
      End
      If @iPos > 0 begin    --Moeda 4
         select @vVLR4 = Sum( B2_VATU4 )
           from SB2### (NoLock) 
          where B2_FILIAL = @cFil_SB2
            and B2_COD = @IN_CODIGO
            and D_E_L_E_T_ = ' '
          group by B2_FILIAL,B2_COD
      End
      If @iPos > 0 begin    --Moeda 5
         select @vVLR5 = Sum( B2_VATU5 )
           from SB2### (NoLock) 
          where B2_FILIAL = @cFil_SB2
            and B2_COD = @IN_CODIGO
            and D_E_L_E_T_ = ' '
          group by B2_FILIAL,B2_COD
      End
    end else begin
      select @vVLR1 = Sum( B2_VATU1 ), 
             @vQTD  = Sum( B2_QATU )
        from SB2### (NoLock) 
       where B2_COD = @IN_CODIGO
         and D_E_L_E_T_ = ' '
       group by B2_COD
      select @iPos = Charindex( '2', @IN_MV_MOEDACM )
      If @iPos > 0 begin    --Moeda 2
         select @vVLR2 = Sum( B2_VATU2 )
           from SB2### (NoLock) 
          where B2_COD = @IN_CODIGO
            and D_E_L_E_T_ = ' '
          group by B2_COD
      End
      If @iPos > 0 begin    --Moeda 3
         select @vVLR3 = Sum( B2_VATU3 )
           from SB2### (NoLock) 
          where B2_COD = @IN_CODIGO
            and D_E_L_E_T_ = ' '
          group by B2_COD
      End
      If @iPos > 0 begin    --Moeda 4
         select @vVLR4 = Sum( B2_VATU4 )
           from SB2### (NoLock) 
          where B2_COD = @IN_CODIGO
            and D_E_L_E_T_ = ' '
          group by B2_COD
      End
      If @iPos > 0 begin    --Moeda 5
         select @vVLR5 = Sum( B2_VATU5 )
           from SB2### (NoLock) 
          where B2_COD = @IN_CODIGO
            and D_E_L_E_T_ = ' '
          group by B2_COD
      End
    end

    if @vQTD  is null or @vQTD = 0 select @vQTD   = 1
    if @vVLR1 is null select @vVLR1  = 0
    if @vVLR2 is null select @vVLR2  = 0
    if @vVLR3 is null select @vVLR3  = 0
    if @vVLR4 is null select @vVLR4  = 0
    if @vVLR5 is null select @vVLR5  = 0

    select @OUT_VLR1 = @vVLR1 / @vQTD
    select @OUT_VLR2 = @vVLR2 / @vQTD 
    select @OUT_VLR3 = @vVLR3 / @vQTD 
    select @OUT_VLR4 = @vVLR4 / @vQTD 
    select @OUT_VLR5 = @vVLR5 / @vQTD 
End