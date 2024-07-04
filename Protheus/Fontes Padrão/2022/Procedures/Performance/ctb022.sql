Create procedure CTB022_##
( 
   @IN_FILIALCOR    Char('CT2_FILIAL'),
   @IN_FILIALATE    Char('CT2_FILIAL'),
   @IN_DATADE       Char(08),
   @IN_DATAATE      Char(08),
   @IN_LMOEDAESP    Char(01),
   @IN_MOEDA        Char('CT7_MOEDA'),
   @IN_TPSALDO      Char('CT2_TPSALD'),
   @IN_MVSOMA       Char(01),
   @OUT_RESULTADO   Char(01) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA190.PRW </s>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  Refaz o arquivo saldo por lote => atualiza CT6 </d>
    Funcao do Siga  -      Ctb190Lote()     - Reprocessa totais por lote  => atualiza CT6
    Entrada         - <ri> @IN_FILIALCOR    - Filial Corrente
                           @IN_FILIALATE    - Filial final do processamento
                           @IN_DATADE       - Data Inicial
                           @IN_DATAATE      - Data Final
                           @IN_LMOEDAESP    - Moeda Especifica - '1', todas, exceto orca/o - '0'
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
                           @IN_MVSOMA       - Soma 2 vezes
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     11/11/2003
-------------------------------------------------------------------------------------- */
declare @cFilial_CT2  char('CT2_FILIAL')
declare @cFilial_CT6  char('CT6_FILIAL')
declare @cFILCT2      char('CT2_FILIAL')
declare @cAux         char(03)
Declare @cCT2_DC      char('CT2_DC')
Declare @cCT2_DATA    Char(08)
Declare @cCT2_LOTE    Char('CT2_LOTE')
Declare @cCT2_SBLOTE  Char('CT2_SBLOTE')
Declare @nCT2_VALOR   Float
Declare @cCT2_MOEDLC  Char('CT2_MOEDLC')
Declare @nCT6_DEBITO  Float
Declare @nCT6_CREDIT  Float
Declare @nCT6_DIG     Float
Declare @nCT6_DEBITOX Float
Declare @nCT6_CREDITX Float
Declare @nCT6_DIGX    Float
Declare @iRecno       Integer
Declare @iRecnoNew    Integer
Declare @iNroRegs     Integer
Declare @iTranCount   Integer --Var.de ajuste para SQLServer e Sybase.
                              -- Será trocada por Commit no CFGX051 após passar pelo Parse

begin
   
   select @OUT_RESULTADO = '0'
   select @iNroRegs = 0
   
   If @IN_FILIALCOR = ' ' select @cFilial_CT2 = ' '
   else select @cFilial_CT2 = @IN_FILIALCOR
   
   Declare CUR_CT190LOTE insensitive cursor for
    Select CT2_FILIAL, CT2_DC, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_MOEDLC, Sum(CT2_VALOR)
      From CT2###
     Where CT2_FILIAL between @cFilial_CT2 and @IN_FILIALATE
       and CT2_DATA   between @IN_DATADE   and @IN_DATAATE
       and CT2_TPSALD   = @IN_TPSALDO
       and ((CT2_MOEDLC = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0')
       and CT2_DC       != '4'
       and D_E_L_E_T_ = ' '
   Group by CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DC, CT2_MOEDLC
   Order by CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DC, CT2_MOEDLC
   for read only
   open CUR_CT190LOTE
   Fetch CUR_CT190LOTE Into @cFILCT2, @cCT2_DC, @cCT2_DATA, @cCT2_LOTE, @cCT2_SBLOTE, @cCT2_MOEDLC, @nCT2_VALOR
   
   While (@@fetch_status = 0) begin
      
      select @cAux = 'CT6'
      exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CT6 OutPut
      
      Select @iNroRegs = @iNroRegs + 1
      Select @nCT6_DEBITO  = 0
      Select @nCT6_CREDIT  = 0
      Select @nCT6_DIG     = 0
      Select @nCT6_DEBITOX = 0
      Select @nCT6_CREDITX = 0
      Select @nCT6_DIGX    = 0
      Select @nCT2_VALOR   = @nCT2_VALOR
      
      Select @iRecno = IsNull( MIN(R_E_C_N_O_),0 )
        From CT6###
       Where CT6_FILIAL = @cFilial_CT6
         and CT6_DATA   = @cCT2_DATA
         and CT6_LOTE   = @cCT2_LOTE
         and CT6_SBLOTE = @cCT2_SBLOTE
         and CT6_MOEDA  = @cCT2_MOEDLC
         and CT6_TPSALD = @IN_TPSALDO
         and D_E_L_E_T_ = ' '
      
      If @iNroRegs = 1 begin
         Begin Transaction
         Select @iNroRegs = @iNroRegs
      End
      If @iRecno = 0 begin
         /* --------------------------------------------------------------------------
            Recupera o R_E_C_N_O_ para ser gravado
            -------------------------------------------------------------------------- */
         select @iRecnoNew = IsNull( MAX(R_E_C_N_O_), 0 ) from CT6###
         select @iRecnoNew = @iRecnoNew + 1
         if @iRecnoNew is null or @iRecnoNew = 0 select @iRecnoNew = 1
         
         if @cCT2_DC IN ('1','3') begin
            select @nCT6_DEBITOX = Round(@nCT2_VALOR, 2)
         end
         if @cCT2_DC IN ('2','3') begin
            select @nCT6_CREDITX = Round(@nCT2_VALOR, 2)
         end
         If @cCT2_DC = '3' begin
            If @IN_MVSOMA = '1' Select @nCT6_DIGX = Round(@nCT2_VALOR, 2)
            else Select @nCT6_DIGX = Round(( 2 * @nCT2_VALOR ), 2)
         end else Select @nCT6_DIGX = Round(@nCT2_VALOR, 2)
         
      end else begin
          
         Select @nCT6_DEBITO = CT6_DEBITO, @nCT6_CREDIT = CT6_CREDIT, @nCT6_DIG = CT6_DIG
           From CT6###
          Where R_E_C_N_O_ = @iRecno
         
         if @cCT2_DC = '1' begin
            select @nCT6_DEBITOX = Round((@nCT6_DEBITO + @nCT2_VALOR), 2)
            select @nCT6_CREDITX = Round(@nCT6_CREDIT, 2)
         end
         if @cCT2_DC = '2' begin
            select @nCT6_CREDITX = Round((@nCT6_CREDIT + @nCT2_VALOR) , 2)
            select @nCT6_DEBITOX = Round(@nCT6_DEBITO,2 )
         end
         If @cCT2_DC = '3' begin
            select @nCT6_DEBITOX = Round((@nCT6_DEBITO + @nCT2_VALOR), 2)
            select @nCT6_CREDITX = Round((@nCT6_CREDIT + @nCT2_VALOR), 2)
            
            If @IN_MVSOMA = '1' Select @nCT6_DIGX = Round((@nCT6_DIG + @nCT2_VALOR), 2)
            else Select @nCT6_DIGX  = Round((@nCT6_DIG + ( 2 * @nCT2_VALOR )), 2)
            
         end else Select @nCT6_DIGX = Round((@nCT6_DIG + @nCT2_VALOR), 2)
         
      end
      /*---------------------------------------------------------------
        Insercao / Atualizacao
      --------------------------------------------------------------- */
      If @iRecno = 0 begin
         Insert into CT6### ( CT6_FILIAL, CT6_MOEDA,   CT6_TPSALD,   CT6_DATA,  CT6_LOTE,  CT6_SBLOTE,
                              CT6_STATUS, CT6_DEBITO,  CT6_CREDIT,   CT6_DIG,   R_E_C_N_O_ )
                     values( @cFilial_CT6, @cCT2_MOEDLC,  @IN_TPSALDO,  @cCT2_DATA, @cCT2_LOTE, @cCT2_SBLOTE,
                              '1',         @nCT6_DEBITOX, @nCT6_CREDITX, @nCT6_DIGX,  @iRecnoNew  )
      end else begin
         Update CT6###
            Set CT6_DEBITO = @nCT6_DEBITOX, CT6_CREDIT = @nCT6_CREDITX, CT6_DIG = @nCT6_DIGX
          Where R_E_C_N_O_ = @iRecno
      End
      
      If @iNroRegs >= 1024 begin
         Commit Transaction
         select @iNroRegs = 0
      End
      Fetch CUR_CT190LOTE Into @cFILCT2, @cCT2_DC, @cCT2_DATA, @cCT2_LOTE, @cCT2_SBLOTE, @cCT2_MOEDLC, @nCT2_VALOR
      
   End
   Close CUR_CT190LOTE
   Deallocate CUR_CT190LOTE
   
   If @iNroRegs > 0 begin
      Commit Transaction
      select @iTranCount = 0
   End
   /*---------------------------------------------------------------
     Se a execucao foi OK retorna '1'
   --------------------------------------------------------------- */
   select @OUT_RESULTADO = '1'
end
