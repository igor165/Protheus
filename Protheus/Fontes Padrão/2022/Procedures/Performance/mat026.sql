Create procedure MAT026_##
( 
   @IN_FILIALCOR    Char('B1_FILIAL'),
   @IN_USUARIO      Char(08),
   @IN_DDATABASE    Char(08),
   @OUT_RESULT      Char(01) Output
)

as

/* ---------------------------------------------------------------------------------------------------------------------
    Versão      :   <v> Protheus P12 </v>
    -----------------------------------------------------------------------------------------------------------------    
    Programa    :   <s> MA350PROCESS (MATA350) </s>
    -----------------------------------------------------------------------------------------------------------------    
    Descricao   :   <d> Grava Saldo atual para final </d>
    -----------------------------------------------------------------------------------------------------------------
    Assinatura  :   <a> 001 </a>
    -----------------------------------------------------------------------------------------------------------------    
    Entrada     :  <ri> @IN_FILIALCOR  - Filial corrente 
                        @IN_USUARIO    - Grava usuário que esta executando
                        @IN_DDATABASE  - Utiliza a Data Base para atusalizar o Saldo </ri>                   
    -----------------------------------------------------------------------------------------------------------------
    Saida       :  <ro> @OUT_RESULTADO - Retorno de processamento </ro>
    -----------------------------------------------------------------------------------------------------------------
    Versão      :   <v> Advanced Protheus 6.09 </v>
    -----------------------------------------------------------------------------------------------------------------
    Observações :   <o> Alterado por Ricardo Gonçalves em 30/01/2002 para funcionar na v. 6.09  </o>
    -----------------------------------------------------------------------------------------------------------------
    Responsavel :   <r> Douglas Morato </r>
    -----------------------------------------------------------------------------------------------------------------
    Data        :  <dt> 16/04/2001 </dt>

    Estrutura de chamadas
    ========= == ========

    0.MAT026 - Grava Saldo atual para final
      1.MAT018 - Converte a Unidade de Medida

    -----------------------------------------------------------------------------------------------------------------
    Obs.: Não remova os tags acima. Os tags são a base para a geração automática, de documentação, pelo Parse.
--------------------------------------------------------------------------------------------------------------------- */

declare @cCod          Char('B1_COD')
declare @cLocal        Char('B1_LOCPAD')
declare @nRecno        integer
declare @nFatorConv    Float
declare @nQSALDOATU    Float
declare @nCUSTOATU     Float
declare @nCUSTOATU2    Float
declare @nCUSTOATU3    Float
declare @nCUSTOATU4    Float
declare @nCUSTOATU5    Float
declare @nQTSEGUM      Float
declare @nB2_VATU1     Float
declare @nB2_VATU2     Float
declare @nB2_VATU3     Float
declare @nB2_VATU4     Float
declare @nB2_VATU5     Float
declare @cFil_SB1      VarChar('B1_FILIAL')
declare @cFil_SB2      VarChar('B2_FILIAL')
declare @cFil_SC2      VarChar('C2_FILIAL')
declare @cFil_AF9      VarChar('C2_FILIAL')
declare @nRec          integer
declare @nRecAnt       integer
declare @nMaxRecnoSC2  integer
declare @nMaxRecnoAF9  integer
declare @nContador     integer
declare @cAux          Varchar(3)
declare @nAux          integer
declare @nAux1         integer
declare @iTranCount    integer --Var.de ajuste para SQLServer e Sybase.
                               -- Será trocada por Commit no CFGX051 após passar pelo Parse

begin 
  /* --------------------------------------------------------------------------------------------
   Define inicio do processo
  -------------------------------------------------------------------------------------------- */
   select @OUT_RESULT = '0' 

   select @cCod         = ' '
   select @cLocal       = ' '
   select @nRecno       = 0
   select @nFatorConv   = 0
   select @nQSALDOATU   = 0
   select @nCUSTOATU    = 0
   select @nCUSTOATU2   = 0
   select @nCUSTOATU3   = 0
   select @nCUSTOATU4   = 0
   select @nCUSTOATU5   = 0
   select @nQTSEGUM     = 0
   select @nB2_VATU1	= 0
   select @nB2_VATU2	= 0
   select @nB2_VATU3	= 0
   select @nB2_VATU4	= 0
   select @nB2_VATU5	= 0
   select @nContador	= 0

   select @cAux = 'SB1'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB1 OutPut
   select @cAux = 'SB2'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB2 OutPut
   select @cAux = 'SC2'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SC2 OutPut
   select @cAux = 'AF9'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_AF9 OutPut

   /* -------------------------------------------------------------------------
    Cursor no SB2 Selecionando todos produtos de acordo filial corrente
   ------------------------------------------------------------------------- */
   declare CUR_A350INI INSENSITIVE cursor for
     select SB2.B2_COD, SB2.B2_LOCAL,   SB2.B2_QATU, SB2.B2_QTSEGUM,
            SB2.B2_CM1, SB2.B2_CM2,     SB2.B2_CM3,  SB2.B2_CM4, 
            SB2.B2_CM5, SB2.B2_VATU1,	SB2.B2_VATU2,SB2.B2_VATU3,
	    SB2.B2_VATU4,SB2.B2_VATU5,  SB2.R_E_C_N_O_, SB1.B1_CONV
       from SB2### SB2, SB1### SB1
      where SB2.B2_FILIAL    = @cFil_SB2 
        and SB1.B1_FILIAL    = @cFil_SB1
        and SB1.B1_COD       = SB2.B2_COD
        and SB2.B2_COD     not like 'MOD%'
        and SB2.D_E_L_E_T_   = ' '
        and SB1.D_E_L_E_T_   = ' '
   for read only

   open CUR_A350INI
   fetch CUR_A350INI
    into  @cCod      , @cLocal      , @nQSALDOATU , @nQTSEGUM  , @nCUSTOATU , @nCUSTOATU2 , @nCUSTOATU3 ,
       	 @nCUSTOATU4, @nCUSTOATU5  , @nB2_VATU1  , @nB2_VATU2 , @nB2_VATU3 , @nB2_VATU4  ,@nB2_VATU5 ,
      	 @nRecno    , @nFatorConv

   while ( @@fetch_status = 0 ) begin
      select @nContador = @nContador + 1
      If ( @nFatorConv <> 0 ) begin
         select @nAux  = 0
         select @nAux1 = 2
			exec MAT018_## @cCod, @IN_FILIALCOR, @nQSALDOATU, @nAux, @nAux1, @nQTSEGUM output
      end       
      If @nContador = 1 begin
         begin tran
         select @nContador = @nContador
      End
      If ( @nQSALDOATU <> 0 )
         update SB2###
            set B2_QFIM  = @nQSALDOATU,              
                B2_QFIM2 = @nQTSEGUM,
                B2_VFIM1 = @nB2_VATU1,
                B2_VFIM2 = @nB2_VATU2,
                B2_VFIM3 = @nB2_VATU3,
                B2_VFIM4 = @nB2_VATU4,
                B2_VFIM5 = @nB2_VATU5,
                B2_CM1   = ( @nB2_VATU1 / @nQSALDOATU ),
                B2_CM2   = ( @nB2_VATU2 / @nQSALDOATU ),
                B2_CM3   = ( @nB2_VATU3 / @nQSALDOATU ),
                B2_CM4   = ( @nB2_VATU4 / @nQSALDOATU ),
                B2_CM5   = ( @nB2_VATU5 / @nQSALDOATU )
         where R_E_C_N_O_ = @nRecno
      else 
         update SB2###
            set B2_QFIM  = @nQSALDOATU,              
                B2_QFIM2 = @nQTSEGUM,
                B2_VFIM1 = @nB2_VATU1,
                B2_VFIM2 = @nB2_VATU2,
                B2_VFIM3 = @nB2_VATU3,
                B2_VFIM4 = @nB2_VATU4,
                B2_VFIM5 = @nB2_VATU5
         where R_E_C_N_O_ = @nRecno
       
      fetch CUR_A350INI
       into  @cCod      , @cLocal      , @nQSALDOATU , @nQTSEGUM  , @nCUSTOATU , @nCUSTOATU2 , @nCUSTOATU3 ,
          	 @nCUSTOATU4, @nCUSTOATU5  , @nB2_VATU1  , @nB2_VATU2 , @nB2_VATU3 , @nB2_VATU4  ,@nB2_VATU5 ,
         	 @nRecno    , @nFatorConv
      if ( @nContador > 1023 ) begin
         Commit Tran
         select @nContador = 0
      end
      
   end -- Loop cursor SB2
   if ( @nContador <> 0 ) begin
      Commit Tran
      select @nContador = 0
      select @iTranCount = 0
   end
   close      CUR_A350INI
   deallocate CUR_A350INI
   
   select @nRec         = 0
   select @nRecAnt      = 0
   select @nMaxRecnoSC2 = 0
   select @nContador    = 0

   /* -------------------------------------------------------------------------
    Cursor no SC2
   ------------------------------------------------------------------------- */
   select @nMaxRecnoSC2 = MAX(R_E_C_N_O_)
     from SC2###  SC2
    where C2_FILIAL  = @cFil_SC2

   if @nMaxRecnoSC2 is null select @nMaxRecnoSC2 = 0
   select @nRec = 0
   while @nRec <= @nMaxRecnoSC2 begin
      select @nContador = @nContador + 1
      select @nRecAnt = @nRec 
      select @nRec = @nRec + 1024
      
      If @nContador = 1 begin
         Begin Tran
         select @nContador = @nContador
      End
      update SC2###
         set C2_VFIM1   = C2_VATU1,
             C2_VFIM2   = C2_VATU2,
             C2_VFIM3   = C2_VATU3,
             C2_VFIM4   = C2_VATU4,
             C2_VFIM5   = C2_VATU5,
             C2_APRFIM1 = C2_APRATU1,
             C2_APRFIM2 = C2_APRATU2,
             C2_APRFIM3 = C2_APRATU3,
             C2_APRFIM4 = C2_APRATU4,
             C2_APRFIM5 = C2_APRATU5
       where R_E_C_N_O_ >  @nRecAnt
         and R_E_C_N_O_ <= @nRec     
         and C2_FILIAL  = @cFil_SC2
         
       If @nContador > 1023 begin
          Commit Tran
          select @nContador = 0
       End
   end
   If @nContador > 0 begin
      Commit Tran
      select @iTranCount = 0
   End
   
   select @nRec         = 0
   select @nRecAnt      = 0
   select @nMaxRecnoAF9 = 0
   select @nContador    = 0

   /* ------------------------------------------------------------------------------------------------------------------
      Cursor no AF9
   ------------------------------------------------------------------------------------------------------------------ */
   select @nMaxRecnoAF9 = MAX(R_E_C_N_O_)
     from AF9### AF9
    where AF9_FILIAL  = @cFil_AF9

   if @nMaxRecnoAF9 is null select @nMaxRecnoAF9 = 0
   select @nRec = 0
   while @nRec <= @nMaxRecnoAF9 begin
      select @nContador = @nContador + 1
      select @nRecAnt = @nRec 
      select @nRec = @nRec + 1024
      
      If @nContador = 1 begin
         Begin Tran
         select @nContador = @nContador
      End
      update AF9###
         set AF9_VFIM1   = AF9_VATU1,
             AF9_VFIM2   = AF9_VATU2,
             AF9_VFIM3   = AF9_VATU3,
             AF9_VFIM4   = AF9_VATU4,
             AF9_VFIM5   = AF9_VATU5
       where R_E_C_N_O_ >  @nRecAnt
         and R_E_C_N_O_ <= @nRec     
         and AF9_FILIAL  = @cFil_AF9
         
      If @nContador > 1023 begin
         Commit Tran
         select @nContador = 0
      End
      
   end
   If @nContador > 0 begin
      Commit tran
      select @iTranCount = 0
   End
   /* -------------------------------------------------------------------------
    Final do processo retornando '1' como processo  encerrado por completo
   ------------------------------------------------------------------------- */
   select @OUT_RESULT = '1'
end
