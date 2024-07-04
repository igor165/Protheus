Create procedure CTB038_##
( 
   @IN_FILIAL    Char('CTU_FILIAL'),
   @IN_IDENT     Char('CTU_IDENT'),
   @IN_MOEDA     Char('CTU_MOEDA'),
   @IN_TPSALDO   Char('CTU_TPSALD'),
   @IN_CODIGO    Char('CTU_CODIGO'),
   @IN_DATA      Char(08),
   @IN_LP        Char('CTU_LP'),
   @IN_DTLP      Char('CTU_DTLP'),
   @IN_STATUS    Char('CTU_STATUS'),
   @IN_SLCOMP    Char('CTU_SLCOMP'),
   @IN_DEBITO    Float,
   @IN_CREDIT    Float,
   @IN_ANTDEB    Float,
   @IN_ANTCRD    Float,
   @IN_ATUDEB    Float,
   @IN_ATUCRD    Float,
   @IN_RECNO     Integer
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA360.PRW </s>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  INSERT no CTU </d>
    Funcao do Siga  -      
    Entrada         - <ri> @IN_FILIAL       - Filial
                           @IN_IDENT        - Identifica a tabela
                           @IN_MOEDA        - Moeda
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
                           @IN_CODIGO       - Codigo
                           @IN_DATA         - Data
                           @IN_LP           - Lucros e perdas
                           @IN_DTLP         - Data de Ap de Lucros e Perdas
                           @IN_STATUS       - Status
                           @IN_SLCOMP       - Sld Composto
                           @IN_DEBITO       - Movimento a debito
                           @IN_CREDIT       - Movimento a credito 
                           @IN_ANTDEB       - sald anterior a debito
                           @IN_ANTCRD       - sald anterior a credito 
                           @IN_ATUDEB       - sald atual a debito
                           @IN_ATUCRD       - sald atual a credito 
                           @IN_RECNO        - Recno
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     24/12/2003
-------------------------------------------------------------------------------------- */

Declare @nDEBITO    Float
Declare @nCREDIT    Float
Declare @nATUDEB    Float
Declare @nATUCRD    Float
Declare @nANTDEB    Float
Declare @nANTCRD    Float
Declare @iRecno     integer
   
begin
   
   select @iRecno   = @IN_RECNO
   select @nDEBITO  =  Round(@IN_DEBITO, 2)
   select @nCREDIT  =  Round(@IN_CREDIT, 2)
   select @nATUDEB  =  Round(@IN_ATUDEB, 2)
   select @nATUCRD  =  Round(@IN_ATUCRD, 2)
   select @nANTDEB  =  Round(@IN_ANTDEB, 2)
   select @nANTCRD  =  Round(@IN_ANTCRD, 2)
   
   ##TRATARECNO @iRecno\
   insert into CTU### ( CTU_FILIAL, CTU_IDENT,  CTU_MOEDA,  CTU_TPSALD, CTU_CODIGO, CTU_DATA,   CTU_LP,
                        CTU_DTLP,   CTU_STATUS, CTU_SLCOMP, CTU_DEBITO, CTU_CREDIT, CTU_ANTDEB, CTU_ANTCRD,
                        CTU_ATUDEB, CTU_ATUCRD, R_E_C_N_O_ )
               values ( @IN_FILIAL, @IN_IDENT,  @IN_MOEDA,  @IN_TPSALDO, @IN_CODIGO, @IN_DATA,   @IN_LP,
                        @IN_DTLP,   @IN_STATUS, @IN_SLCOMP, @nDEBITO,    @nCREDIT,   @nANTDEB,   @nANTCRD,
                        @nATUDEB,   @nATUCRD,   @iRecno )
   ##FIMTRATARECNO
end
