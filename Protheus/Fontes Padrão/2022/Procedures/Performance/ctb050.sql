Create procedure CTB050_##
( 
   @IN_FILIAL    Char('CTY_FILIAL'),
   @IN_MOEDA     Char('CTY_MOEDA'),
   @IN_TPSALDO   Char('CTY_TPSALD'),
   @IN_CUSTO     Char('CTY_CUSTO'),
   @IN_ITEM      Char('CTY_ITEM'),
   @IN_CLVL      Char('CTY_CLVL'),
   @IN_DATA      Char(08),
   @IN_LP        Char('CTY_LP'),
   @IN_DTLP      Char('CTY_DTLP'),
   @IN_STATUS    Char('CTY_STATUS'),
   @IN_SLCOMP    Char('CTY_SLCOMP'),
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
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  INSERT no CTY </d>
    Fonte Microsiga - <s>  Ctba360.PRW </s>
    Funcao do Siga  -      
    Entrada         - <ri> @IN_FILIAL       - Filial
                           @IN_MOEDA        - Moeda
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
                           @IN_CUSTO        - CCusto
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
   insert into CTY### ( CTY_FILIAL, CTY_MOEDA,  CTY_TPSALD, CTY_CUSTO,  CTY_ITEM,   CTY_CLVL  , CTY_DATA,   CTY_LP,
                        CTY_DTLP,   CTY_STATUS, CTY_SLCOMP, CTY_DEBITO, CTY_CREDIT, CTY_ANTDEB, CTY_ANTCRD,
                        CTY_ATUDEB, CTY_ATUCRD, R_E_C_N_O_ )
               values ( @IN_FILIAL, @IN_MOEDA,  @IN_TPSALDO, @IN_CUSTO,  @IN_ITEM,   @IN_CLVL, @IN_DATA,   @IN_LP,
                        @IN_DTLP,   @IN_STATUS, @IN_SLCOMP,  @nDEBITO,   @nCREDIT,   @nANTDEB, @nANTCRD,
                        @nATUDEB,   @nATUCRD,   @iRecno  )
   ##FIMTRATARECNO
end
