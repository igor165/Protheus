#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'
#include 'totvs.ch'


function GTPA700G(lAut, lOpc)
Local oModelG6T  := FwLoadModel("GTPA700X")
Local oMdlG6Y	 := oModelG6T:GetModel("G6YDETAIL")
Local cAliasQry	 := GetNextAlias()
Local cAliasQry2 := GetNextAlias()
Local cAliasQry3 := GetNextAlias()
Local nValorTax	 := 0
Local aArray 	 := {}
Local cParc		 := ''
Local cNum		 := ''
Local cNatTit	 := ''
Local cTitChave  := ''
Local lRet		 := .T.
Local lRetMsg	 := .T.

private lMsErroAuto	:= .F.

Default lAut := .F.
Default lOpc := .F.

if !lAut
	lRetMsg := MsgYesNo("Gerar somente o titulo para localidades que ainda não foram geradas nesse caixa?")
Else
	lRetMsg := lOpc
EndIf

If lRetMsg
	If Select(cAliasQry) > 0
		(cAliasQry)->(dbCloseArea())
	Endif
	
	BeginSQL Alias cAliasQry
		
		SELECT  
			SUM(G6Y_VALOR) VALORTOT, G6Y_LOCORI
		FROM 
			%Table:G6Y% G6Y
		WHERE 
			G6Y_FILIAL = %xFilial:G6Y%
			AND G6Y_CODIGO = %Exp:G6T->G6T_CODIGO%
			AND G6Y_CODAGE = %Exp:G6T->G6T_AGENCI%
			AND G6Y_TPLANC = '4' 
			AND G6Y_AGRUPA = 'T'
			AND G6Y_CHVTX = '' 
			AND %NotDel%
			GROUP BY G6Y_LOCORI
	
	EndSQL
	
Else
	If Select(cAliasQry) > 0
		(cAliasQry)->(dbCloseArea())
	Endif
	
	BeginSQL Alias cAliasQry
		
		SELECT  
			SUM(G6Y_VALOR) VALORTOT, G6Y_LOCORI, G6Y_CHVTX
		FROM 
			%Table:G6Y% G6Y
		WHERE 
			G6Y_FILIAL = %xFilial:G6Y%
			AND G6Y_CODIGO = %Exp:G6T->G6T_CODIGO%
			AND G6Y_CODAGE = %Exp:G6T->G6T_AGENCI%
			AND G6Y_TPLANC = '4'
			 AND G6Y_AGRUPA = 'T'
			AND %NotDel%
			GROUP BY G6Y_LOCORI,G6Y_CHVTX
	
	EndSQL
				
Endif
		
If (cAliasQry)->(!Eof())
	While (cAliasQry)->(!Eof()) .AND. lRet 
		nValorTax := 0
		nValorTax := (cAliasQry)->VALORTOT
		lRet := .T.
		If !lRetMsg
			SE2->(DbSetOrder(1))
			If SE2->(DbSeek((cAliasQry)->G6Y_CHVTX)) 
				If SE2->E2_SALDO == SE2->E2_VALOR
						aTitSE2 := {}
						lMsErroAuto := .F.
						aTitSE2 := {	{ "E2_PREFIXO"	, SE2->E2_PREFIXO		            , Nil },; //Prefixo 
						 				{ "E2_NUM"		, SE2->E2_NUM  					    , Nil },; //Numero
								 		{ "E2_PARCELA"	, SE2->E2_PARCELA				    , Nil },; //Parcela
										{ "E2_TIPO"		, SE2->E2_TIPO					    , Nil },; //Tipo
						 				{ "E2_NATUREZ"	, SE2->E2_NATUREZ			        , Nil },; //Natureza
						 				{ "E2_FORNECE"	, SE2->E2_FORNECE				    , Nil },; //Cliente
						 				{ "E2_LOJA"		, SE2->E2_LOJA			 		    , Nil },; //Loja
						 				{ "E2_EMISSAO"	, SE2->E2_EMISSAO		         	, Nil },; //Data Emissão
						 				{ "E2_VENCTO"	, SE2->E2_VENCTO				    , Nil },; //Data Vencimento
						 				{ "E2_VENCREA"	, SE2->E2_VENCREA				    , Nil },; //Data Vencimento Real
						 				{ "E2_VALOR"	, SE2->E2_VALOR				        , Nil },; //Valor
						 				{ "E2_SALDO"	, SE2->E2_SALDO					    , Nil },; //Saldo
						 				{ "E2_HIST"		, SE2->E2_HIST						, Nil },; //HIstórico
						 				{ "E2_ORIGEM"	, "GTPA700D"						, Nil }}  //Origem
						 				
						 MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aTitSE2,, 5) // Exclui o título
						
						If lMsErroAuto
							lRet := .F.
							MostraErro()
						Else
							lRet := .T.
						Endif
					
					
				Else
					FwAlertHelp("SALDO", "O título: " + SE2->E2_NUM + " já foi baixado" ) // "Agência", // "Informe uma Agência válida"
					lRet := .F.
				Endif
			Endif
		Endif
		
		If lRet
			// gera titulo no contas a pagar de taxas de bilhetes
			aArray := {}
			cParc	:= '1'
			cNum	:=  GETSXENUM('SE2', 'E2_NUM')
			cNatTit	:= GTPGetRules('NATUPAG')
			
			cTitChave := xFilial("SE2")+"TAX"+cNum+cParc+" "+"TF"+" "
			
			GI1->(DbSetOrder(1))
			GI1->(DbSeek(xFilial("GI1")+ (cAliasQry)->G6Y_LOCORI))
			If !Empty(GI1->GI1_FORMUN) .AND.  !Empty(GI1->GI1_LJFRMN)
				aAdd( aArray,	{"E2_PREFIXO" 	, 'TAX'				, NIL 	} )
				aAdd( aArray,	{"E2_NUM" 		, cNum 				, NIL 	} )
				aAdd( aArray,	{"E2_TIPO" 		, "TF" 				, NIL 	} )
				aAdd( aArray,	{"E2_PARCELA" 	, cParc				, NIL 	} )
				aAdd( aArray,	{"E2_NATUREZ" 	, cNatTit			, NIL 	} )
				aAdd( aArray,	{"E2_FORNECE"	, GI1->GI1_FORMUN	, Nil 	} )
				aAdd( aArray,	{"E2_LOJA"   	, GI1->GI1_LJFRMN  	, Nil 	} )
				aAdd( aArray,	{"E2_EMISSAO"	, dDataBase			, Nil 	} )
				aAdd( aArray,	{"E2_VENCTO" 	, dDataBase			, NIL 	} )
				aAdd( aArray, 	{"E2_VENCREA" 	, dDataBase			, NIL 	} )
				aAdd( aArray,	{"E2_MOEDA" 	, 1					, NIL 	} )
				aAdd( aArray,	{"E2_VALOR" 	, nValorTax			, NIL 	} )
				aAdd( aArray,	{"E2_HIST"		, G6T->G6T_CODIGO+G6T->G6T_AGENCI	, NIL } )
				aAdd( aArray,	{"E2_ORIGEM" 	, 'GTPA700D'		, NIL 	} )
				lMsErroAuto	:= .F.
				MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3)
				
				If lMsErroAuto
					lRet := .F.
					MostraErro()
				Else
					lRet := .T.
					CONFIRMSX8()
						
					BeginSQL Alias cAliasQry2
			
						SELECT  
							G6Y_CODIGO, G6Y_CODAGE, G6Y_NUMFCH, G6Y_LOCORI
						FROM 
							%Table:G6Y% G6Y
						WHERE 
							G6Y_FILIAL = %xFilial:G6Y%
							AND G6Y_CODIGO = %Exp:G6T->G6T_CODIGO%
							AND G6Y_CODAGE = %Exp:G6T->G6T_AGENCI%
							AND G6Y_TPLANC = '4'
							 AND G6Y_AGRUPA = 'T'
							AND %NotDel%
							
						
					EndSQL
			
	
					While (cAliasQry2)->(!Eof()) .AND. lRet 
						lRet := .T.
						CONFIRMSX8()					
						oModelG6T:SetOperation(MODEL_OPERATION_UPDATE)
						oModelG6T:Activate()
						If ( oMdlG6Y:SeekLine({{"G6Y_CODIGO",(cAliasQry2)->G6Y_CODIGO},{"G6Y_CODAGE",(cAliasQry2)->G6Y_CODAGE},{"G6Y_NUMFCH",(cAliasQry2)->G6Y_NUMFCH},{"G6Y_LOCORI",(cAliasQry2)->G6Y_LOCORI}}) )
							lRet := oMdlG6Y:SetValue("G6Y_CHVTX"  , cTitChave)
						Else
							lRet := .F.	
						Endif
						If ( lRet .And. oModelG6T:VldData() )
							oModelG6T:CommitData()	
						EndIf
			
						oModelG6T:DeActivate()
												
						(cAliasQry2)->(dbSkip())
					End
					If Select(cAliasQry2) > 0
						(cAliasQry2)->(dbCloseArea())
					Endif
				Endif
			Else
				lRet := .F.
			Endif
		Endif		
		(cAliasQry)->(dbSkip())
	End
Else
	lRet := .F.
Endif


If Select(cAliasQry3) > 0
	(cAliasQry3)->(dbCloseArea())
Endif
	
BeginSQL Alias cAliasQry3
	
	SELECT  
		G6Y_CHVTX,G6Y_CODIGO, G6Y_CODAGE, G6Y_NUMFCH, G6Y_LOCORI
	FROM 
		%Table:G6Y% G6Y
	WHERE 
		G6Y_FILIAL = %xFilial:G6Y%
		AND G6Y_CODIGO = %Exp:G6T->G6T_CODIGO%
		AND G6Y_CODAGE = %Exp:G6T->G6T_AGENCI%
		AND G6Y_TPLANC = '4' 
		AND G6Y_AGRUPA = 'F'
		AND G6Y_CHVTX <> '' 
		AND %NotDel%
		

EndSQL

If (cAliasQry3)->(!Eof())
	While (cAliasQry3)->(!Eof())
		SE2->(DbSetOrder(1))
		If SE2->(DbSeek((cAliasQry3)->G6Y_CHVTX)) 
				aTitSE2 := {}
				lMsErroAuto := .F.
				aTitSE2 := {	{ "E2_PREFIXO"	, SE2->E2_PREFIXO		            , Nil },; //Prefixo 
			 				{ "E2_NUM"		, SE2->E2_NUM  					    , Nil },; //Numero
					 		{ "E2_PARCELA"	, SE2->E2_PARCELA				    , Nil },; //Parcela
							{ "E2_TIPO"		, SE2->E2_TIPO					    , Nil },; //Tipo
			 				{ "E2_NATUREZ"	, SE2->E2_NATUREZ			        , Nil },; //Natureza
			 				{ "E2_FORNECE"	, SE2->E2_FORNECE				    , Nil },; //Cliente
			 				{ "E2_LOJA"		, SE2->E2_LOJA			 		    , Nil },; //Loja
			 				{ "E2_EMISSAO"	, SE2->E2_EMISSAO		         	, Nil },; //Data Emissão
			 				{ "E2_VENCTO"	, SE2->E2_VENCTO				    , Nil },; //Data Vencimento
			 				{ "E2_VENCREA"	, SE2->E2_VENCREA				    , Nil },; //Data Vencimento Real
			 				{ "E2_VALOR"	, SE2->E2_VALOR				        , Nil },; //Valor
			 				{ "E2_SALDO"	, SE2->E2_SALDO					    , Nil },; //Saldo
			 				{ "E2_HIST"		, SE2->E2_HIST						, Nil },; //HIstórico
			 				{ "E2_ORIGEM"	, "GTPA700D"						, Nil }}  //Origem
			 				
			 MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aTitSE2,, 5) // Exclui o título
			
			If lMsErroAuto		
				MostraErro()
			Else
				
				oModelG6T:SetOperation(MODEL_OPERATION_UPDATE)
				oModelG6T:Activate()
				If ( oMdlG6Y:SeekLine({{"G6Y_CODIGO",(cAliasQry3)->G6Y_CODIGO},{"G6Y_CODAGE",(cAliasQry3)->G6Y_CODAGE},{"G6Y_NUMFCH",(cAliasQry3)->G6Y_NUMFCH},{"G6Y_LOCORI",(cAliasQry3)->G6Y_LOCORI}}) )
					oMdlG6Y:SetValue("G6Y_CHVTX"  , '')
				Endif
				If ( oModelG6T:VldData() )
					oModelG6T:CommitData()	
				EndIf
			
				oModelG6T:DeActivate()
						
					
			Endif
		Endif
		(cAliasQry3)->(DbSkip())
	End
Endif
	
	
If Valtype(oModelG6T) = "O"
	oModelG6T:DeActivate()
	oModelG6T:Destroy()
	oModelG6T:= nil
EndIf	
If Select(cAliasQry) > 0
	(cAliasQry)->(dbCloseArea())
Endif

If Select(cAliasQry2) > 0
	(cAliasQry2)->(dbCloseArea())
Endif

If Select(cAliasQry3) > 0
	(cAliasQry3)->(dbCloseArea())
Endif

If lRet
	Aviso("Geração de Titulo de Taxa", "Títulos gerados com sucesso", {'OK'}, 2) // "Geração de Titulo de Taxa", //Títulos gerados com sucesso

Else

	Aviso("Geração de Titulo de Taxa", "Não foi Possivel gerar os títulos ou não há titulos a serem gerados", {'OK'}, 2) // "Abre Caixa", //Não foi Possivel gerar os títulos
Endif		
		
		
		

return


/*/{Protheus.doc} G700  
    
    @type  Static Function
    @author Fernando Amorim(Cafu)
    @since 03/11/2017
    @version version
    @param oModel, objeto, instância da Classe FwFormModel
    @return lRet, lógico, .t. - Efetuou o Commit com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
Function GETchvtX(cCaixa,cAgencia,cFicha,cLocOri) 

Local cAliasQry3 := GetNextAlias()
Local cRet		  := ''


If Select(cAliasQry3) > 0
	(cAliasQry3)->(dbCloseArea())
Endif
	
BeginSQL Alias cAliasQry3
	
	SELECT  
		G6Y_CHVTX
	FROM 
		%Table:G6Y% G6Y1
	WHERE
		G6Y1.R_E_C_N_O_ = (SELECT MAX(R_E_C_N_O_)
			FROM 
				%Table:G6Y% G6Y2
			WHERE
				G6Y_FILIAL = %xFilial:G6Y%
				AND G6Y_CODIGO = %Exp:cCaixa%
				AND G6Y_CODAGE = %Exp:cAgencia%
				AND G6Y_NUMFCH = %Exp:cFicha%
				AND G6Y_LOCORI  = %Exp:cLocOri%
				AND G6Y_TPLANC = '4' 		
				AND %NOTDEL%)
		

EndSQL

If (cAliasQry3)->(!Eof())
	 cRet := 	(cAliasQry3)->G6Y_CHVTX

EndIf

If Select(cAliasQry3) > 0
	(cAliasQry3)->(dbCloseArea())
Endif

Return cRet
