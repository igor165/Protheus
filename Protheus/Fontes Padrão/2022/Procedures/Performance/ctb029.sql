Create procedure CTB029_##
( 
   @IN_FILIAL    Char('CT3_FILIAL'),
   @IN_CONTA     Char('CT3_CONTA'),
   @IN_CUSTO     Char('CT3_CUSTO'),
   @IN_MOEDA     Char('CT3_MOEDA'),
   @IN_DATA      Char(08),
   @IN_TPSALDO   Char('CT3_TPSALD'),
   @IN_SLBASE    Char('CT3_SLBASE'),
   @IN_DTLP      Char('CT3_DTLP'),
   @IN_LP        Char('CT3_LP'),
   @IN_STATUS    Char('CT3_STATUS'),
   @IN_DEBITO    Float,
   @IN_CREDIT    Float,
   @IN_ATUDEB    Float,
   @IN_ATUCRD    Float,
   @IN_LPDEB     Float,
   @IN_LPCRD     Float,
   @IN_ANTDEB    Float,
   @IN_ANTCRD    Float,
   @IN_SLCOMP    Char('CT3_SLCOMP'),
   @IN_RECNO     Integer
 )
as

/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P.11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA190.PRW </s>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  Insert no CT3 /d>
    Funcao do Siga  -      
    Entrada         - <ri> @IN_FILIAL       - Filial Corrente
                           @IN_CONTA        - Conta
                           @IN_CUSTO        - C Custo
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
                           @IN_ANTCRD       - sl ant a Credito
                           @IN_SLCOMP       - Flag sld compostosl COMPOSTO
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
   Insert into CT3### 
         ( CT3_FILIAL,  CT3_CONTA,  CT3_CUSTO,  CT3_MOEDA,  CT3_DATA,
           CT3_TPSALD,  CT3_SLBASE, CT3_DTLP,   CT3_LP,     CT3_STATUS,
           CT3_DEBITO,  CT3_CREDIT, CT3_ATUDEB, CT3_ATUCRD, CT3_LPDEB,
           CT3_LPCRD,   CT3_ANTDEB, CT3_ANTCRD, CT3_SLCOMP, R_E_C_N_O_ )
   values( @IN_FILIAL,  @IN_CONTA,  @IN_CUSTO,  @IN_MOEDA,  @IN_DATA,
           @IN_TPSALDO, @IN_SLBASE, @IN_DTLP,   @IN_LP,     @IN_STATUS,
           @nDEBITO,    @nCREDIT,   @nATUDEB,   @nATUCRD,   @nLPDEB,
           @nLPCRD,     @nANTDEB,   @nANTCRD,   @IN_SLCOMP, @iRecno )
   ##FIMTRATARECNO
end
