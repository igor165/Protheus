CREATE PROCEDURE MAT014_##
(
   @IN_FILIALCOR    Char('B1_FILIAL'),
   @IN_TRB_COD      Char('B1_COD'),
   @IN_TRB_SEQ      Char(06),
   @IN_TRB_DOC      Char('CM_REMITO;D1_DOC'),
   @IN_TRB_DTORIG   Char(08),
   @IN_TRB_RECALIAS Integer,
   @IN_TRB_CF       Char('D3_CF'),
   @IN_CCF          Char(03),
   @IN_CLOCCQ       Char('B2_LOCAL'),
   @IN_TAM_TRB_DOC  Integer,
   @IN_LOCAL_TRB    Char('B2_LOCAL'),
   @IN_MV_CQ        Char('B2_LOCAL'),
   @IN_MV_PAR11     integer,
   @IN_TRB_ORDEM    Char(03),
   @IN_TRB_NIVEL    Char('D3_NIVEL;G1_NIV'),
   @IN_TRB_ALIAS    Char(03),
   @IN_MV_PAR18     integer
)

as
/* ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus 12 </v>
    Programa    -  <s> A330ESTRU </s>
    Descricao   -  <d> Verifica se o produto da transferencia tem estrutura </d>
    Assinatura  -  <a> 001 </a>
    Entrada     -  <ri>
                   @IN_FILIALCOR    - Filial Corrente
                   @IN_COD          - Codigo do Produto no TRB
                   @IN_SEQ          - Numero da Sequencia (OP)
                   @IN_DOC          - Numero do Documento
                   @IN_DTORIG       - Data (D1 DTDIGIT) (D2 EMISSAO) (D3 EMISSAO)
                   @IN_TRB_RECALIAS - Recno Registro D1, D2 ou D3
                   @IN_CF           - Tipo de Requisicao / Devoucao (RE/DE)
                   @IN_CCF          - Tipo de Requisicao / Devoucao (RE/DE)
                   @IN_CLOCCQ       - Local(Almoxarifado) Controle de Qualidade
                   @IN_TAM_TRB_DOC  - Tamanho do campo Documento no arquivo de trabalho
                   @IN_LOCAL_TRB    - Local da Localizacao (Almoxarifado)
                   @IN_MV_CQ        - Local da Localizacao (Almoxarifado Control Quali.)
                   @IN_MV_PAR11     - Gera estrutura p/movimentos
                   </ri>
    Responsavel :  <r> Marco Norbiato </r>
    Data        :  <dt> 20/03/2000 </dt>
<o> Uso         :  MATA330 </o>
--------------------------------------------------------------------------------------------------------------------- */

declare @cFil_SD7    VarChar('D7_FILIAL')
declare @cFil_SG1    VarChar('G1_FILIAL')
declare @cFil_SD1    VarChar('D1_FILIAL')
declare @nRecno      Integer
declare @cTRB_CF     VarChar('D3_CF')
declare @cTRB_COD    VarChar('B1_COD')
declare @cTRB_DOC    VarChar('D1_DOC;D2_DOC;CM_REMITO')
declare @lFlagCQ     integer
declare @lAcertaMOV  integer
declare @lEstru      VarChar(01)
declare @vNivel      Integer
declare @cNivel      Char('D3_NIVEL;G1_NIV')
declare @cTRB_NIVSD3 VarChar(01)
declare @Tamanho     integer
declare @cAux        Varchar(3)
declare @cNovoNivel  VarChar('D3_NIVEL;G1_NIV')
declare @nContador   integer
declare @iTranCount  integer --Var.de ajuste para SQLServer e Sybase.
                             -- Será trocada por Commit no CFGX051 após passar pelo Parse


begin
   select @lFlagCQ    = 0
   select @lAcertaMOV = 0
   select @Tamanho    = @IN_TAM_TRB_DOC
   select @cNivel     = ' '
   select @lEstru     = '0'
   select @cNovoNivel = ' '
   select @cAux       = 'SD7'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SD7 OutPut
   select @cAux       = 'SG1'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SG1 OutPut
   
   /*-------------------------------------------------------------------
      Pega Registro do arquivo temporario para atualizacoes (Recno vindo de cima !!!)
   */-------------------------------------------------------------------
   select @cTRB_DOC = Substring( @IN_TRB_DOC, 1, @Tamanho )
   if ( @IN_TRB_CF IN ( 'RE4','RE7','RE6' ) ) begin
      /*-------------------------------------------------------------------
       Ativa flag que indica que material veio do CQ atraves de PRODUCAO
      */-------------------------------------------------------------------
      if ( @IN_LOCAL_TRB = @IN_MV_CQ ) begin
         select @nRecno = null
         select @nRecno = MIN(R_E_C_N_O_)
           from SD7### SD7
          where  SD7.D7_FILIAL  = @cFil_SD7
            and  SD7.D7_PRODUTO = @IN_TRB_COD
            and  SD7.D7_NUMSEQ  = @IN_TRB_SEQ
            and  SD7.D7_NUMERO  = @cTRB_DOC
            and  SD7.D7_ORIGLAN = 'PR'
            and  SD7.D_E_L_E_T_ = ' '
         if ( @nRecno is not null ) begin
            select @lFlagCQ = 1
            if ( Substring(@IN_TRB_CF,2,2) = 'E6' ) select @lAcertaMOV = 1
         end
         
         select @nRecno = null
         select @nRecno = MIN(R_E_C_N_O_)
           from SD7### SD7
          where  SD7.D7_FILIAL  = @cFil_SD7
            and  SD7.D7_PRODUTO = @IN_TRB_COD
            and  SD7.D7_NUMSEQ  = @IN_TRB_SEQ
            and  SD7.D7_NUMERO  = @cTRB_DOC
            and  SD7.D7_ORIGLAN <>'PR'
            and  SD7.D_E_L_E_T_ = ' '
         if ( @nRecno is not null ) begin
            if (@IN_TRB_NIVEL is not Null) and (@IN_TRB_ALIAS ='SD1' and @IN_TRB_ORDEM <> '100')
               select @cNovoNivel = @IN_TRB_NIVEL
         end
      end
      /*-------------------------------------------------------------------
      Declaracao do cursor para iniciar atualizaçao
      */-------------------------------------------------------------------
      select @nContador  = 0
      select @cNivel = '  '
      declare Cursor_TRB insensitive cursor for
         select R_E_C_N_O_, TRB_CF, TRB_COD
           from TRB### TRB
          where TRB_FILIAL = @IN_FILIALCOR
            and TRB_ALIAS  = 'SD3'
            and TRB_SEQ    = @IN_TRB_SEQ
            and TRB_DTORIG = @IN_TRB_DTORIG
            and substring( TRB_CF,2,2 ) = substring( @IN_CCF,2,2 )
       order by TRB_CF desc
      open Cursor_TRB
      fetch Cursor_TRB into @nRecno, @cTRB_CF, @cTRB_COD
      
      while ( @@Fetch_Status = 0 ) begin
         Select @nContador = @nContador + 1
         if ( substring( @cTRB_CF,1,1 ) = 'R' ) begin
            if ( @IN_MV_PAR11 = 1 ) begin
               select @lEstru  = '1'
	            select @cNivel = Isnull( Min( substring(G1_NIVINV,1,2) ), '  ' )
   	           from TRB###SG1 SG1
      	       where SG1.G1_FILIAL  = @IN_FILIALCOR
         	      and SG1.G1_COD     = @cTRB_COD
            	   and SG1.D_E_L_E_T_ = ' '
            end else begin
               select @lEstru  = '1'
               select @cNivel = Isnull( Min( substring(G1_NIVINV,1,2) ), '  ' )
                 from SG1### SG1
                where SG1.G1_FILIAL  = @cFil_SG1
                  and SG1.G1_COD     = @cTRB_COD
                  and SG1.D_E_L_E_T_ = ' '
            end
         end
         /*-------------------------------------------------------------------
          Encontrado produto no arquivo de estrutura !!!
         */-------------------------------------------------------------------
         If ( ( ( substring( @cTRB_CF,1,1 ) = 'R' ) and ( @cNivel <> ' ' ) ) or ( ( Substring(@IN_TRB_CF,2,2) = 'E4' ) and ( @IN_MV_PAR11 <> 1 ) ) ) begin
            select @lEstru  = '1'
         End
         If @nContador = 1 begin
            Begin tran
            select @nContador = @nContador
         End
         /*-------------------------------------------------------------------
         Indica se grava mov. do CQ atraves de producao com "RE4/DE4"
         */-------------------------------------------------------------------
         If ( ( substring( @cTRB_CF,2,2 ) = 'E6' ) and ( @lFlagCQ = 1 ) and ( @lAcertaMOV = 1 ) ) begin
            update SD3###
               set D3_CF      = substring( D3_CF, 1, 2 ) || '4'
             where R_E_C_N_O_ = @IN_TRB_RECALIAS
         end
         if ( @lEstru = '1' ) begin
            if ( ( @cTRB_CF = 'DE4' ) or ( @cTRB_CF = 'RE4' ) or ( @cTRB_CF = 'DE7' ) or ( @cTRB_CF = 'RE7' ) )
               select @cNivel = substring( @cNivel,1,2 ) || 'w'
            else
               select @cNivel = substring( @cNivel,1,2 ) || ' '
         end else begin
            if @cNovoNivel = ' ' select @cNivel = '  w'
            else select @cNivel = @cNovoNivel
         end
         if ( substring( @cTRB_CF,2,2 ) = 'E6' ) begin
            if @IN_MV_PAR18 = 1 select @cTRB_NIVSD3 = '1'
            else  select @cTRB_NIVSD3 = '9'
         end else select @cTRB_NIVSD3 = '5'
         if @cNivel is null select @cNivel = ' '
         update TRB###
            set TRB_NIVEL  = @cNivel,
                TRB_NIVSD3 = @cTRB_NIVSD3,
                TRB_TIPO   = 'T'
          where R_E_C_N_O_ = @nRecno
         
         fetch Cursor_TRB into @nRecno, @cTRB_CF, @cTRB_COD
         
         If @nContador > 1023 begin
            Commit Tran
            select @nContador = 0
         End
         
      end
      close      Cursor_TRB
      deallocate Cursor_TRB
      
      If @nContador > 0 begin
         Commit Tran
         select @iTranCount = 0
      End
   end
end
