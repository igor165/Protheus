Create procedure CTB041_##
( 
   @IN_FILIAL    Char('CTV_FILIAL'),
   @IN_MOEDA     Char('CTV_MOEDA'),
   @IN_TPSALDO   Char('CTV_TPSALD'),
   @IN_CUSTO     Char('CTV_CUSTO'),
   @IN_ITEM      Char('CTV_ITEM'),
   @IN_DATA      Char(08),
   @IN_LP        Char('CTV_LP'),
   @IN_DTLP      Char('CTV_DTLP'),
   @IN_STATUS    Char('CTV_STATUS'),
   @IN_SLCOMP    Char('CTV_SLCOMP'),
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
    Fonte Microsiga - <s>  CTBXSAL.PRW </s>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  INSERT no CTV </d>
    Funcao do Siga  -      
    Entrada         - <ri> @IN_FILIAL       - Filial
                           @IN_MOEDA        - Moeda
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
                           @IN_CUSTO        - CCusto
                           @IN_ITEM         - Item
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
    Data        :     30/12/2003
-------------------------------------------------------------------------------------- */

Declare @nDEBITO    Float
Declare @nCREDIT    Float
Declare @nATUDEB    Float
Declare @nATUCRD    Float
Declare @nANTDEB    Float
Declare @nANTCRD    Float
Declare @iRecno     Integer

begin
   
   select @iRecno   =  @IN_RECNO
   select @nDEBITO  =  Round(@IN_DEBITO, 2)
   select @nCREDIT  =  Round(@IN_CREDIT, 2)
   select @nATUDEB  =  Round(@IN_ATUDEB, 2)
   select @nATUCRD  =  Round(@IN_ATUCRD, 2)
   select @nANTDEB  =  Round(@IN_ANTDEB, 2)
   select @nANTCRD  =  Round(@IN_ANTCRD, 2)
   
   ##TRATARECNO @iRecno\
   insert into CTV### ( CTV_FILIAL, CTV_MOEDA,  CTV_TPSALD, CTV_CUSTO,  CTV_ITEM  , CTV_DATA,   CTV_LP,
                        CTV_DTLP,   CTV_STATUS, CTV_SLCOMP, CTV_DEBITO, CTV_CREDIT, CTV_ANTDEB, CTV_ANTCRD,
                        CTV_ATUDEB, CTV_ATUCRD, R_E_C_N_O_ )
               values ( @IN_FILIAL, @IN_MOEDA,  @IN_TPSALDO, @IN_CUSTO,  @IN_ITEM , @IN_DATA,   @IN_LP,
                        @IN_DTLP,   @IN_STATUS, @IN_SLCOMP,  @nDEBITO,   @nCREDIT,  @nANTDEB,   @nANTCRD,
                        @nATUDEB,   @nATUCRD,   @iRecno  )
   ##FIMTRATARECNO
end
