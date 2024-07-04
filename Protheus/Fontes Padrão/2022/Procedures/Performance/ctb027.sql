Create procedure CTB027_##
( 
   @IN_FILIAL    Char('CT7_FILIAL'),
   @IN_CONTA     Char('CT7_CONTA'),
   @IN_MOEDA     Char('CT7_MOEDA'),
   @IN_DATA      Char(08),
   @IN_TPSALDO   Char('CT7_TPSALD'),
   @IN_SLBASE    Char('CT7_SLBASE'),
   @IN_DTLP      Char('CT7_DTLP'),
   @IN_LP        Char('CT7_LP'),
   @IN_STATUS    Char('CT7_STATUS'),
   @IN_DEBITO    Float,
   @IN_CREDIT    Float,
   @IN_ATUDEB    Float,
   @IN_ATUCRD    Float,
   @IN_LPDEB     Float,
   @IN_LPCRD     Float,
   @IN_ANTDEB    Float,
   @IN_ANTCRD    Float,
   @IN_RECNO     Integer
 )
as

/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P.11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA190.PRW </s>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  Insert no CT7 </d>
    Funcao do Siga  -      
    Entrada         - <ri> @IN_FILIAL       - Filial Corrente
                           @IN_CONTA        - Conta
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
                           @IN_RECNO        - nro do recno </ri>
    Saida           - <o>   </ro
    Responsavel :     <r>  Alice Yaeko Yamamoto	</r>
    Data        :     21/11/2003
-------------------------------------------------------------------------------------- */

Declare @nDEBITO    Float
Declare @nCREDIT    Float
Declare @nATUDEB    Float
Declare @nATUCRD    Float
Declare @nANTDEB    Float
Declare @nANTCRD    Float
Declare @nLPDEB     Float
Declare @nLPCRD     Float
Declare @iRecno     Integer
   
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
   Insert into CT7### 
         ( CT7_FILIAL, CT7_CONTA,  CT7_MOEDA,  CT7_DATA,   CT7_TPSALD,
           CT7_SLBASE, CT7_DTLP,   CT7_LP,     CT7_STATUS, CT7_DEBITO,
           CT7_CREDIT, CT7_ATUDEB, CT7_ATUCRD, CT7_LPDEB,  CT7_LPCRD,
           CT7_ANTDEB, CT7_ANTCRD, R_E_C_N_O_ )
   values( @IN_FILIAL, @IN_CONTA,  @IN_MOEDA,  @IN_DATA,   @IN_TPSALDO,
           @IN_SLBASE, @IN_DTLP,   @IN_LP,     @IN_STATUS, @nDEBITO,
           @nCREDIT,   @nATUDEB,   @nATUCRD,   @nLPDEB,    @nLPCRD,
           @nANTDEB,   @nANTCRD,   @iRecno )
   ##FIMTRATARECNO
end
