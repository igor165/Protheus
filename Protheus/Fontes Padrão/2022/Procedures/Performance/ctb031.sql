Create procedure CTB031_##
( 
   @IN_FILIAL    Char('CT4_FILIAL'),
   @IN_CONTA     Char('CT4_CONTA'),
   @IN_CUSTO     Char('CT4_CUSTO'),
   @IN_ITEM      Char('CT4_ITEM'),
   @IN_MOEDA     Char('CT4_MOEDA'),
   @IN_DATA      Char(08),
   @IN_TPSALDO   Char('CT4_TPSALD'),
   @IN_SLBASE    Char('CT4_SLBASE'),
   @IN_DTLP      Char('CT4_DTLP'),
   @IN_LP        Char('CT4_LP'),
   @IN_STATUS    Char('CT4_STATUS'),
   @IN_DEBITO    Float,
   @IN_CREDIT    Float,
   @IN_ATUDEB    Float,
   @IN_ATUCRD    Float,
   @IN_LPDEB     Float,
   @IN_LPCRD     Float,
   @IN_ANTDEB    Float,
   @IN_ANTCRD    Float,
   @IN_SLCOMP    Char( 'CT4_SLCOMP' ),
   @IN_RECNO     Integer
 )
as

/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA190.PRW </s>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  Insert no CT7 </d>
    Funcao do Siga  -      
    Entrada         - <ri> @IN_FILIAL       - Filial Corrente
                           @IN_CONTA        - Conta
                           @IN_CUSTO        - C Custo
                           @IN_ITEM         - Item
                           @IN_MOEDA        - Moeda
                           @IN_DATA         - Data
                           @IN_TPSALDO      - Tipo de Saldo
                           @IN_SLBASE       - Saldo base
                           @IN_DTLP         - Data LP
                           @IN_LP           - LP
                           @IN_STATUS       - Status
                           @IN_DEBITO       - movito a debito
                           @IN_CREDIT       - movito a credito
                           @IN_ATUDEB       - Saldo atual a debito
                           @IN_ATUCRD       - Saldo atual a credito
                           @IN_LPDEB        - lp a debito
                           @IN_LPCRD        - lp a credito
                           @IN_ANTDEB       - sl ant a Debito
                           @IN_ANTCRD       - sl ant a Debito
                           @IN_SLCOMP       - Flag de sld composto
                           @IN_RECNO        - nro do recno </ri>
    Saida           - <o>   </ro
    Responsavel :     <r>  Alice Yaeko Yamamoto	</r>
    Data        :     28/11/2003
-------------------------------------------------------------------------------------- */

Declare @nDEBITO    Float
Declare @nCREDIT    Float
Declare @nATUDEB    Float
Declare @nATUCRD    Float
Declare @nANTDEB    Float
Declare @nANTCRD    Float
Declare @nLPDEB     Float
Declare @nLPCRD     Float
Declare @iRecno     integer
   
begin
   
   select @iRecno   = @IN_RECNO
   select @nDEBITO  =  Round(@IN_DEBITO, 2)
   select @nCREDIT  =  Round(@IN_CREDIT, 2)
   select @nATUDEB  =  Round(@IN_ATUDEB, 2)
   select @nATUCRD  =  Round(@IN_ATUCRD, 2)
   select @nANTDEB  =  Round(@IN_ANTDEB, 2)
   select @nANTCRD  =  Round(@IN_ANTCRD, 2)
   select @nLPDEB   =  Round(@IN_LPDEB, 2)
   select @nLPCRD   =  Round(@IN_LPCRD, 2)
    
   ##TRATARECNO @iRecno\
   Insert into CT4### 
         ( CT4_FILIAL,  CT4_CONTA,   CT4_CUSTO,  CT4_ITEM,   CT4_MOEDA,
           CT4_DATA,    CT4_TPSALD,  CT4_SLBASE, CT4_DTLP,   CT4_LP,
           CT4_STATUS,  CT4_DEBITO,  CT4_CREDIT, CT4_ATUDEB, CT4_ATUCRD,
           CT4_LPDEB,   CT4_LPCRD,   CT4_ANTDEB, CT4_ANTCRD, CT4_SLCOMP,
           R_E_C_N_O_ )
   values( @IN_FILIAL,  @IN_CONTA,   @IN_CUSTO,  @IN_ITEM,   @IN_MOEDA,
           @IN_DATA,    @IN_TPSALDO, @IN_SLBASE, @IN_DTLP,   @IN_LP,
           @IN_STATUS,  @nDEBITO,    @nCREDIT,   @nATUDEB,   @nATUCRD,
           @nLPDEB,     @nLPCRD,     @nANTDEB,   @nANTCRD,   @IN_SLCOMP,
           @iRecno )
   ##FIMTRATARECNO
end
