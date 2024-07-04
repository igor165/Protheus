Create procedure CTB047_##
( 
   @IN_FILIAL    Char('CTX_FILIAL'),
   @IN_MOEDA     Char('CTX_MOEDA'),
   @IN_TPSALDO   Char('CTX_TPSALD'),
   @IN_ITEM      Char('CTX_ITEM'),
   @IN_CLVL      Char('CTX_CLVL'),
   @IN_DATA      Char(08),
   @IN_LP        Char('CTX_LP'),
   @IN_DTLP      Char('CTX_DTLP'),
   @IN_STATUS    Char('CTX_STATUS'),
   @IN_SLCOMP    Char('CTX_SLCOMP'),
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
    Fonte Microsiga - <s>  Ctba360.PRW </s>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  INSERT no CTX </d>
    Funcao do Siga  -      
    Entrada         - <ri> @IN_FILIAL       - Filial
                           @IN_MOEDA        - Moeda
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
                           @IN_ITEM         - Item
                           @IN_CLVL         - ClVl
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
    Data        :     02/01/2004
-------------------------------------------------------------------------------------- */

Declare @nDEBITO    Float
Declare @nCREDIT    Float
Declare @nATUDEB    Float
Declare @nATUCRD    Float
Declare @nANTDEB    Float
Declare @nANTCRD    Float
Declare @iRecno     integer

begin
   
   select @iRecno   =  @IN_RECNO
   select @nDEBITO  =  Round(@IN_DEBITO, 2)
   select @nCREDIT  =  Round(@IN_CREDIT, 2)
   select @nATUDEB  =  Round(@IN_ATUDEB, 2)
   select @nATUCRD  =  Round(@IN_ATUCRD, 2)
   select @nANTDEB  =  Round(@IN_ANTDEB, 2)
   select @nANTCRD  =  Round(@IN_ANTCRD, 2)
   
   ##TRATARECNO @iRecno\
   insert into CTX### ( CTX_FILIAL, CTX_MOEDA,  CTX_TPSALD, CTX_ITEM,   CTX_CLVL  , CTX_DATA,   CTX_LP,
                        CTX_DTLP,   CTX_STATUS, CTX_SLCOMP, CTX_DEBITO, CTX_CREDIT, CTX_ANTDEB, CTX_ANTCRD,
                        CTX_ATUDEB, CTX_ATUCRD, R_E_C_N_O_ )
               values ( @IN_FILIAL, @IN_MOEDA,  @IN_TPSALDO, @IN_ITEM,   @IN_CLVL, @IN_DATA,  @IN_LP,
                        @IN_DTLP,   @IN_STATUS, @IN_SLCOMP,  @nDEBITO,   @nCREDIT, @nANTDEB,  @nANTCRD,
                        @nATUDEB,   @nATUCRD,   @iRecno  )
   ##FIMTRATARECNO
end
