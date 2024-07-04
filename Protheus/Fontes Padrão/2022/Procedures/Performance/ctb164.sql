Create Procedure CTB164_##(
   @IN_FILIAL        Char( 'CT7_FILIAL' ),
	@IN_DATA          Char( 08 ), 
 	@IN_CONTAC        Char( 'CT7_CONTA' ),
 	@IN_CONTAD        Char( 'CT7_CONTA' ),
   @IN_CUSTOC        Char( 'CT3_CUSTO' ),
   @IN_CUSTOD        Char( 'CT3_CUSTO' ),
   @IN_ITEMC         Char( 'CT4_ITEM' ),
   @IN_ITEMD         Char( 'CT4_ITEM' ),
   @IN_CLVLC         Char( 'CTI_CLVL' ), 
   @IN_CLVLD         Char( 'CTI_CLVL' ), 
   @IN_TPSALDO       Char( 'CT7_TPSALD' ),
   @IN_MOEDA         Char( 'CT7_MOEDA' ),
   @IN_INTEGRIDADE   Char(01),
   @OUT_RESULT       Char( 01 ) Output
)
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA102.PRW </s>
    Descricao       - <d>  Apaga registros com saldo em branco </d>
    Funcao do Siga  -      CTB102Proc()
    Entrada         - <ri> @IN_FILIAL       - Filial corrente da manutencao do arquivo de lanctos
	                        @IN_DATA         - Data Base
                         	@IN_CONTAC       - Conta Credito
                         	@IN_CONTAD       - Conta Debito
                           @IN_CUSTOC       - Centro de Custo Credito
                           @IN_CUSTOD       - Centro de Custo Debito
                           @IN_ITEMC        - Item Credito
                           @IN_ITEMD        - Item Debito
                           @IN_CLVLC        - Classe de Valor Credito
                           @IN_CLVLD        - Classe de Valor Credito 
                           @IN_TPSALDO      - Tipo de Saldo 
                           @IN_MOEDA        - Moeda Específica
                           @IN_LP           - Lucros e Perdas
                           @IN_INTEGRIDADE  - '1' se a integridade estiver ligada, '0' se nao estiver ligada.   </ri>
    Saida           - <o>  @OUT_RESULT      - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Ricardo C Pereira	</r>
    Data        :     30/09/2005
-------------------------------------------------------------------------------------- */
Declare  @cFilial_CT7    Char( 'CT7_FILIAL' )
Declare  @cFilial_CT3    Char( 'CT3_FILIAL' )
Declare  @cFilial_CT4    Char( 'CT4_FILIAL' )
Declare  @cFilial_CTI    Char( 'CTI_FILIAL' )
Declare  @cAux           VarChar( 03 )

begin
   
   select @OUT_RESULT = '0'
   
   select @cAux = 'CT7'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT7 OutPut
   select @cAux = 'CT3'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT3 OutPut
   select @cAux = 'CT4'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT4 OutPut
   select @cAux = 'CTI'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CTI OutPut
   
   If @IN_INTEGRIDADE = '1' begin
		begin tran
			UpDate CT7###
			Set D_E_L_E_T_ = '*'
			Where CT7_FILIAL  = @cFilial_CT7
			  and CT7_DEBITO   = 0
              and CT7_CREDIT   = 0 
              and CT7_DATA     = @IN_DATA
              and ((CT7_CONTA  = @IN_CONTAC) or (CT7_CONTA = @IN_CONTAD))
              and CT7_TPSALD   = @IN_TPSALDO
      
			delete from CT7###
         	Where CT7_FILIAL  = @cFilial_CT7
              and CT7_DEBITO   = 0
              and CT7_CREDIT   = 0 
              and CT7_DATA     = @IN_DATA
              and ((CT7_CONTA  = @IN_CONTAC) or (CT7_CONTA = @IN_CONTAD))
              and CT7_TPSALD   = @IN_TPSALDO
              and CT7_MOEDA    = @IN_MOEDA
              and CT7_LP       = 'N'
              and D_E_L_E_T_   = '*'
        commit tran
   end else begin
		begin tran
			delete from CT7###
   			Where CT7_FILIAL  = @cFilial_CT7
			  and CT7_DEBITO   = 0
			  and CT7_CREDIT   = 0 
   	          and CT7_DATA     = @IN_DATA
   	          and ((CT7_CONTA  = @IN_CONTAC) or (CT7_CONTA = @IN_CONTAD))
   	          and CT7_TPSALD   = @IN_TPSALDO
   	          and CT7_MOEDA    = @IN_MOEDA
   	          and CT7_LP       = 'N'
   	          and D_E_L_E_T_   = ' '
   	     commit tran
   End
   
   If @IN_INTEGRIDADE = '1' begin
		begin tran
			UpDate CT3###
			Set D_E_L_E_T_   = '*'
			Where CT3_FILIAL   = @cFilial_CT3
              and CT3_DEBITO   = 0
              and CT3_CREDIT   = 0 
   	          and CT3_DATA     = @IN_DATA
              and ((CT3_CONTA  = @IN_CONTAC AND CT3_CUSTO = @IN_CUSTOC) or (CT3_CONTA  = @IN_CONTAD AND CT3_CUSTO = @IN_CUSTOD))
              and CT3_TPSALD   = @IN_TPSALDO
              and CT3_MOEDA    = @IN_MOEDA
              and CT3_LP       = 'N'
              and D_E_L_E_T_   = ' '
      
			delete from CT3###
   			Where CT3_FILIAL   = @cFilial_CT3
              and CT3_DEBITO   = 0
              and CT3_CREDIT   = 0 
              and CT3_DATA     = @IN_DATA
              and ((CT3_CONTA  = @IN_CONTAC AND CT3_CUSTO = @IN_CUSTOC) or (CT3_CONTA  = @IN_CONTAD AND CT3_CUSTO = @IN_CUSTOD))
              and CT3_TPSALD   = @IN_TPSALDO
              and CT3_MOEDA    = @IN_MOEDA
              and CT3_LP       = 'N'
              and D_E_L_E_T_   = '*'
       commit tran
   end else begin
		begin tran
			delete from CT3###
   			Where CT3_FILIAL  = @cFilial_CT3
              and CT3_DEBITO   = 0
              and CT3_CREDIT   = 0 
   	          and CT3_DATA     = @IN_DATA
   	          and ((CT3_CONTA  = @IN_CONTAC AND CT3_CUSTO = @IN_CUSTOC) or (CT3_CONTA  = @IN_CONTAD AND CT3_CUSTO = @IN_CUSTOD))
   	          and CT3_TPSALD   = @IN_TPSALDO
   	          and CT3_MOEDA    = @IN_MOEDA
   	          and CT3_LP       = 'N'
   	          and D_E_L_E_T_   = ' '
   	    commit tran
   End
   
   If @IN_INTEGRIDADE = '1' begin
		begin tran
			UpDate CT4###
			Set D_E_L_E_T_ = '*'
			Where CT4_FILIAL  = @cFilial_CT4
              and CT4_DEBITO   = 0
              and CT4_CREDIT   = 0 
              and CT4_DATA     = @IN_DATA
              and  ((CT4_CONTA = @IN_CONTAC AND CT4_CUSTO = @IN_CUSTOC AND CT4_ITEM = @IN_ITEMC) 
               or (CT4_CONTA = @IN_CONTAD AND CT4_CUSTO = @IN_CUSTOD AND CT4_ITEM = @IN_ITEMD))
              and CT4_TPSALD   = @IN_TPSALDO
              and CT4_MOEDA    = @IN_MOEDA
              and CT4_LP       = 'N'
              and D_E_L_E_T_   = ' '
      
			delete from CT4###
   			Where CT4_FILIAL  = @cFilial_CT4
              and CT4_DEBITO   = 0
              and CT4_CREDIT   = 0 
   	          and CT4_DATA     = @IN_DATA
   	          and  ((CT4_CONTA = @IN_CONTAC AND CT4_CUSTO = @IN_CUSTOC AND CT4_ITEM = @IN_ITEMC) 
               or (CT4_CONTA = @IN_CONTAD AND CT4_CUSTO = @IN_CUSTOD AND CT4_ITEM = @IN_ITEMD))
   	          and CT4_TPSALD   = @IN_TPSALDO
   	          and CT4_MOEDA    = @IN_MOEDA
   	          and CT4_LP       = 'N'
   	          and D_E_L_E_T_   = '*'
   	    commit tran
   end else begin
		begin tran
			delete from CT4###
    		Where CT4_FILIAL  = @cFilial_CT4
			  and CT4_DEBITO   = 0
              and CT4_CREDIT   = 0 
              and CT4_DATA     = @IN_DATA
              and ((CT4_CONTA = @IN_CONTAC AND CT4_CUSTO = @IN_CUSTOC AND CT4_ITEM = @IN_ITEMC) 
               or (CT4_CONTA = @IN_CONTAD AND CT4_CUSTO = @IN_CUSTOD AND CT4_ITEM = @IN_ITEMD))
              and CT4_TPSALD   = @IN_TPSALDO
              and CT4_MOEDA    = @IN_MOEDA
              and CT4_LP       = 'N'
              and D_E_L_E_T_   = ' '
        commit tran
   end
   
   If @IN_INTEGRIDADE = '1' begin
		begin tran
			Update CTI###
			Set D_E_L_E_T_   = '*'
			Where CTI_FILIAL   = @cFilial_CTI
              and CTI_DEBITO   = 0
              and CTI_CREDIT   = 0 
              and CTI_DATA     = @IN_DATA
              and  ((CTI_CONTA = @IN_CONTAC AND CTI_CUSTO = @IN_CUSTOC AND CTI_ITEM = @IN_ITEMC AND CTI_CLVL = @IN_CLVLC) 
               or (CTI_CONTA = @IN_CONTAD AND CTI_CUSTO = @IN_CUSTOD AND CTI_ITEM = @IN_ITEMD AND CTI_CLVL = @IN_CLVLD))
              and CTI_TPSALD   = @IN_TPSALDO
              and CTI_MOEDA    = @IN_MOEDA
              and CTI_LP       = 'N'
              and D_E_L_E_T_   = ' '
      
			delete from CTI###
   			Where CTI_FILIAL  = @cFilial_CTI
              and CTI_DEBITO   = 0
              and CTI_CREDIT   = 0 
   	          and CTI_DATA     = @IN_DATA
   	          and  ((CTI_CONTA = @IN_CONTAC AND CTI_CUSTO = @IN_CUSTOC AND CTI_ITEM = @IN_ITEMC AND CTI_CLVL = @IN_CLVLC) 
               or (CTI_CONTA = @IN_CONTAD AND CTI_CUSTO = @IN_CUSTOD AND CTI_ITEM = @IN_ITEMD AND CTI_CLVL = @IN_CLVLD))
   	          and CTI_TPSALD   = @IN_TPSALDO
    	      and CTI_MOEDA    = @IN_MOEDA
   	          and CTI_LP       = 'N'
         	  and D_E_L_E_T_   = '*'
        commit tran 
   end else begin
		begin tran
			delete from CTI###
   			Where CTI_FILIAL  = @cFilial_CTI
              and CTI_DEBITO   = 0
              and CTI_CREDIT   = 0 
   	          and CTI_DATA     = @IN_DATA
   	          and  ((CTI_CONTA = @IN_CONTAC AND CTI_CUSTO = @IN_CUSTOC AND CTI_ITEM = @IN_ITEMC AND CTI_CLVL = @IN_CLVLC) 
               or (CTI_CONTA = @IN_CONTAD AND CTI_CUSTO = @IN_CUSTOD AND CTI_ITEM = @IN_ITEMD AND CTI_CLVL = @IN_CLVLD))
   	          and CTI_TPSALD   = @IN_TPSALDO
    	      and CTI_MOEDA    = @IN_MOEDA
   	          and CTI_LP       = 'N'
    	      and D_E_L_E_T_   = ' '
    	commit tran
   End
   select @OUT_RESULT = '1'
   
end
