#INCLUDE "PROTHEUS.CH"
#INCLUDE "FATA520.CH" 

#DEFINE NTAMCOD 2

Static cVendIgn		:= Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA520   บAutor  ณVendas CRM          บ Data ณ  08/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibicao da amarracao entre vendedores e contas             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA520                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fata520()

Private aRotina		:= MenuDef()
Private cCadastro	:= STR0014	//"Contas de vendedores"

DbSelectArea("SX2")
DbSetOrder(1)

mBrowse(,,,,"ADL")

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt520Proc บAutor  ณVendas CRM          บ Data ณ  07/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa a base de clientes, suspects e prospects de cada   บฑฑ
ฑฑบ          ณvendedor, dentro dos parametros.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpL1    - Flag para interromper o processamento            บฑฑ
ฑฑบ          ณExpC2    - Codigo do vendedor inicial para processamento    บฑฑ
ฑฑบ          ณExpC3    - Codigo do vendedor final para processamento      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA520                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft520Proc(lEnd,cVendDe,cVendAte)

Local aArea	   		:= GetArea()				// Armazena posicionamento atual
Local aAreaSA3 		:= SA3->(GetArea())		// Armazena posicionamento da tabela SA3
Local aRecnos  		:= {}						// Lista com os recnos que serao deletados
Local cFilADL  		:= xFilial("ADL")			// Filial para a tabela ADL
Local cFilAD1  		:= xFilial("AD1")			// Filial para a tabela AD1
Local cFilAD2  		:= xFilial("AD2")			// Filial para a tabela AD2
Local cFilSA3		:= xFilial("SA3")			// Filial para a tabela SA3
Local cFilACH		:= xFilial("ACH")			// Filial para a tabela ACH
Local nX			:= 0     					// Auxiliar de loop
Local aPDFields	 	:= {"A3_NOME"}
Local lPDObfuscate	:= .F.
Local cNomeVend		:= ""

Default lEnd		:= .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe a nova workarea estiver ativaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !TcGetdb() $ "POSTGRES/INFORMIX" .And. !RddName() $ "CTREE"
	Return Ft520Proc2(lEnd, cVendDe, cVendAte)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRecupera lista de vendedores ignoradosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cVendIgn == NIL
	cVendIgn	:= SuperGetMv("MV_FATVIGN",,"")
EndIf

DbSelectArea("AD1")
DbSetOrder(2)	//AD1_FILIAL+AD1_VEND+DTOS(AD1_DTINI)

DbSelectArea("AD2")
DbSetOrder(2)	//AD2_FILIAL+AD2_VEND+AD2_NROPOR+AD2_REVISA

DbSelectArea("SA3")

nX := RecCount()
ProcRegua(nX)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe o reprocessamento for completo, limpa a ADL via SQLณ
//ณpara agilizar o processo                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(cVendDe) .AND. ("ZZZZZZ" $ AllTrim(Upper(cVendAte)))
	Ft520Limpa(.T.)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณReprocessamento dos vendedoresณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSetOrder(1) //A3_FILIAL+A3_COD
DbSeek(cFilSA3+cVendDe,.T.)


FTPDLoad(Nil,Nil,aPDFields)    
lPDObfuscate := FTPDIsObfuscate("A3_NOME")
If lPDObfuscate
	cNomeVend := FTPDObfuscate(SA3->A3_NOME)
EndIf

While !SA3->(Eof()) 			.AND.;
	SA3->A3_FILIAL	== cFilSA3	.AND.;
	SA3->A3_COD		<= cVendAte

	If !lPDObfuscate
		cNomeVend := AllTrim(SA3->A3_NOME)
	EndIf 
	IncProc(STR0008 + AllTrim(SA3->A3_COD) + " - " + cNomeVend) //"Processando vendedor "
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDescarta ignoradoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If AllTrim(SA3->A3_COD) $ cVendIgn
		SA3->(DbSkip())
		Loop
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTratamento para o botao cancelaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lEnd .And. (lEnd := ApMsgNoYes(STR0009,STR0010)) //"Deseja cancelar a execu็ใo do processo?"##"Interromper"
		Exit
	EndIf
	                
	ADL->(DbSetOrder(4)) //ADL_FILIAL+ADL_VEND+ADL_FILENT+ADL_ENTIDA+ADL_CODENT+ADL_LOJENT
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณApaga registros existentesณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ADL->(DbSeek(cFilADL+SA3->A3_COD))

		aRecnos	:= {}	             	

		While !ADL->(Eof()) 			.AND.;
			ADL->ADL_FILIAL	== cFilADL	.AND.;
			ADL->ADL_VEND	== SA3->A3_COD
			
			AAdd(aRecnos,ADL->(Recno()))
			ADL->(DbSkip())
			
		End
		
		Begin Transaction
		For nX := 1 to Len(aRecnos)
			ADL->(DbGoTo(aRecnos[nX]))
			RecLock("ADL",.F.)
			DbDelete()
			MsUnLock()
		Next nX

		End Transaction
		
	EndIf
	
	ADL->(DbSetOrder(1))	//ADL_FILIAL+ADL_CODOPO+ADL_VEND
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRecria registros das entidades com a ADLณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	

	//Recria vinculos com Suspects
	DbSelectArea("ACH")
	DbSetOrder(5)
	DbSeek(xFilial("ACH")+SA3->A3_COD)
	
	While !ACH->(Eof()) 				.AND.;
		ACH->ACH_FILIAL	== cFilACH 		.AND.;
		ACH->ACH_VEND	== SA3->A3_COD
		
		If Empty(ACH->ACH_CODPRO)
			RecLock("ADL",.T.)
			Replace ADL_FILIAL	With cFilADL
			Replace ADL_VEND	With SA3->A3_COD
			Replace ADL_FILENT	With cFilACH
			Replace ADL_ENTIDA	With "ACH"
			Replace ADL_CODENT	With ACH->ACH_CODIGO
			Replace ADL_LOJENT	With ACH->ACH_LOJA
			
			Replace ADL_NVLSTR	With SA3->A3_NVLSTR
			
			For nX := SA3->A3_NIVEL to 1 Step -1
				Replace &("ADL_NIVE"+StrZero(nX,2))	 With Left(SA3->A3_NVLSTR,nX*NTAMCOD)
			Next      
			
			MsUnLock()
		EndIf
		
		ACH->(DbSkip())

	End
 	
 	//Recria vinculos com Prospects
 	Ft520RpSUS()                  
 	
 	//Recria vinculos com Clientes
 	Ft520RpSA1()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณLeitura do cabecalho (AD1)ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	AD1->(DbSetOrder(2))	//AD1_FILIAL+AD1_VEND+DTOS(AD1_DTINI)
	AD1->(DbSeek(cFilAD1+SA3->A3_COD))
	
	While !AD1->(Eof())				.AND.;
		AD1->AD1_FILIAL	== cFilAD1	.AND.;
		AD1->AD1_VEND	== SA3->A3_COD
		
		If ADL->(!DbSeek(cFilADL+AD1->AD1_NROPOR+SA3->A3_COD))
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณInsere registro como contaณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If !Empty(AD1->AD1_PROSPE)
				Ft520InsOp(	3	   			, AD1->AD1_VEND		, "SUS"		, AD1->AD1_PROSPE	,;
			 				AD1->AD1_LOJPRO	, AD1->(AD1_NROPOR+AD1_REVISA)	)
			Else
				Ft520InsOp(	3	   			, AD1->AD1_VEND		, "SA1"		, AD1->AD1_CODCLI	,;
			 				AD1->AD1_LOJCLI	, AD1->(AD1_NROPOR+AD1_REVISA)	)
			End 
			
			If !Empty(AD1->AD1_NUMORC) .AND. ADL->(DbSeek(cFilADL+AD1->AD1_NROPOR+AD1->AD1_VEND))
	 	
		 		DbSelectArea("ADL")
		 		RecLock("ADL",.F.)
		 		ADL->ADL_CODORC	:= AD1->AD1_NUMORC
		 		MsUnLock()
		 		DbSelectArea("AD1")
	 	
		 	EndIf

		EndIf
		
		AD1->(DbSkip()) 
		
	End
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณLeitura do time (AD2)ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	AD1->(DbSetOrder(1)) //AD1_FILIAL+AD1_NROPOR+AD1_REVISA
	AD2->(DbSeek(cFilAD2+SA3->A3_COD))
	
	While !AD2->(Eof())				.AND.;
		AD2->AD2_FILIAL	== cFilAD2	.AND.;
		AD2->AD2_VEND	== SA3->A3_COD
		
		If AD1->(DbSeek(cFilAD1+AD2->AD2_NROPOR+AD2->AD2_REVISA))	.AND.;
			ADL->(!DbSeek(cFilADL+AD1->AD1_NROPOR+AD2->AD2_VEND))
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณInsere registro como contaณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If !Empty(AD1->AD1_PROSPE)
				Ft520InsOp(	3	   			, AD2->AD2_VEND		, "SUS"		, AD1->AD1_PROSPE	,;
			 				AD1->AD1_LOJPRO	, AD1->(AD1_NROPOR+AD1_REVISA)	)
			Else
				Ft520InsOp(	3	   			, AD2->AD2_VEND		, "SA1"		, AD1->AD1_CODCLI	,;
			 				AD1->AD1_LOJCLI	, AD1->(AD1_NROPOR+AD1_REVISA)	)
			End

		 	If !Empty(AD1->AD1_NUMORC) .AND. ADL->(DbSeek(cFilADL+AD1->AD1_NROPOR+AD2->AD2_VEND))
		 	
		 		DbSelectArea("ADL")
		 		RecLock("ADL",.F.)
		 		ADL->ADL_CODORC	:= AD1->AD1_NUMORC
		 		MsUnLock()
		 	
		 	EndIf                                     
			 	
		EndIf
	
		AD2->(DbSkip()) 
	
	End	
	
	SA3->(DbSkip())
	
End

FTPDLogUser('FT520PROC')

//Finaliza o gerenciamento dos campos com prote็ใo de dados.
FTPDUnLoad()

RestArea(aAreaSA3)
RestArea(aArea)


Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt520InsOpบAutor  ณVendas CRM          บ Data ณ  21/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInsere vinculo entre entidade e vendedor a partir da oportu-บฑฑ
ฑฑบ          ณnidade                                                      บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpN1 - Numero da operacao (3-Inclusao,4-Alteracao,etc.)    บฑฑ
ฑฑบ          ณExpC2 - Codigo do vendedor                                  บฑฑ
ฑฑบ          ณExpC3 - Alias da entidade                                   บฑฑ
ฑฑบ          ณExpC4 - Codigo da entidade                                  บฑฑ
ฑฑบ          ณExpC5 - Loja da entidade                                    บฑฑ
ฑฑบ          ณExpC6 - Codigo da oportunidade/proposta/orcamento           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA520                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft520InsOp(	nOper	, cVendedor	, cEntidade	, cCodigo	,;
		 				cLoja	, cChave	)
Local lRet	:= Ft520Ins(	nOper	, cVendedor	, cEntidade	, cCodigo	,;
		  	   				cLoja	, 1			, cChave	, cChave	)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt520InsOrบAutor  ณVendas CRM          บ Data ณ  21/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInsere vinculo entre entidade e vendedor a partir do orca-  บฑฑ
ฑฑบ          ณmento                                                       บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpN1 - Numero da operacao (3-Inclusao,4-Alteracao,etc.)    บฑฑ
ฑฑบ          ณExpC2 - Codigo da entidade                                  บฑฑ
ฑฑบ          ณExpC3 - Loja da entidade                                    บฑฑ
ฑฑบ          ณExpC4 - Codigo da proposta/orcamento                        บฑฑ
ฑฑบ          ณExpC5 - Codigo da oportunidade                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA520                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft520InsOr(nOper	, cCodigo	, cLoja		, cChave	,;
					cOportu	)

Local lRet		:= .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSomente inclui relacionamento se o orcamento foi gerado aณ
//ณpartir da oportunidade de vendas                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If IsInCallStack("FATA300")
	lRet	:=  Ft520Ins(	nOper	, M->AD1_VEND	, "SA1"		, cCodigo	,;
			  				cLoja	, 2				, cChave	, cOportu	)
EndIf

Return lRet
		 				
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt520InsPrบAutor  ณVendas CRM          บ Data ณ  21/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInsere vinculo entre entidade e vendedor a partir da propos-บฑฑ
ฑฑบ          ณta                                                          บฑฑ   
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpN1 - Numero da operacao (3-Inclusao,4-Alteracao,etc.)    บฑฑ
ฑฑบ          ณExpC2 - Codigo do vendedor                                  บฑฑ
ฑฑบ          ณExpC3 - Alias da entidade                                   บฑฑ
ฑฑบ          ณExpC4 - Codigo da entidade                                  บฑฑ
ฑฑบ          ณExpC5 - Loja da entidade                                    บฑฑ
ฑฑบ          ณExpC6 - Codigo da oportunidade/proposta/orcamento           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA520                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft520InsPr(	nOper	, cVendedor	, cEntidade	, cCodigo	,;
		 				cLoja	, cChave	, cOportu	)
Local lRet	:= Ft520Ins(	nOper	, cVendedor	, cEntidade	, cCodigo	,;
		  					cLoja	, 3			, cChave	, cOportu	)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt520AltEnบAutor  ณMicrosiga           บ Data ณ  10/15/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAlteracao da entidade no controle de contas.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpN1 - Numero da operacao (3-Inclusao,4-Alteracao,etc.)    บฑฑ
ฑฑบ          ณExpC2 - Codigo do vendedor                                  บฑฑ
ฑฑบ          ณExpC3 - Alias da entidade                                   บฑฑ
ฑฑบ          ณExpC4 - Codigo da entidade                                  บฑฑ
ฑฑบ          ณExpC5 - Loja da entidade                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA520                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft520AltEn(nOper	, cVendedor	, cEntidade	, cCodigo	,;
		 			cLoja	)

Local lRet :=	Ft520InEnt(	nOper	, cVendedor	, cEntidade	, cCodigo	,;
		 			  		cLoja	) 

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt520Ins  บAutor  ณVendas CRM          บ Data ณ  12/21/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInsere/Atualiza os dados de controle de contas do vendedor  บฑฑ
ฑฑบ          ณna tabela ADL                                               บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpN1 - Numero da operacao (3-Inclusao,4-Alteracao,etc.)    บฑฑ
ฑฑบ          ณExpC2 - Codigo do vendedor                                  บฑฑ
ฑฑบ          ณExpC3 - Alias da entidade                                   บฑฑ
ฑฑบ          ณExpC4 - Codigo da entidade                                  บฑฑ
ฑฑบ          ณExpC5 - Loja da entidade                                    บฑฑ
ฑฑบ          ณExpN6 - Opcao que indica se e orcamento(2) ou proposta(3)   บฑฑ
ฑฑบ          ณExpC7 - Proposta/orcamento                                  บฑฑ
ฑฑบ          ณExpC8 - Codigo da oportunidade                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA520                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft520Ins(	nOper	, cVendedor	, cEntidade	, cCodigo	,;
		 			  		cLoja	, nOpcao	, cChave	, cOportu	)

Local aArea		:= GetArea() 			// Armazena o posicionamento atual
Local aAreaADL	:= ADL->(GetArea())	// Armazena o posiciomanento da tabela ADL
Local aAreaSA3	:= SA3->(GetArea())	// Armazena o posiciomanento da tabela ADL
Local cFilADL	:= xFilial("ADL")		// Codigo de filial da tabela ADL
Local lRet		:= .T.					// Retorno da funcao 
Local aEntDel	:= {}					// Lista de relacionamentos a eliminar para a entidade
Local aRecDel	:= {}					// Lista de relacionamentos a serem eliminados antes da gravacao
Local lFirstRec	:= .F.					// Indica se sera gravado o primeiro registro
Local cFilEnt	:= ""					// Filial da entidade validada      
Local nX		:= 0					// Auxiliar de loop   

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRecupera lista de vendedores ignoradosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cVendIgn == NIL
	cVendIgn	:= SuperGetMv("MV_FATVIGN",,"")
EndIf

If AllTrim(cVendedor) $ cVendIgn
	RestArea(aArea)
	Return lRet
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida o vendedorณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SA3")
DbSetOrder(1)
lRet		:= !Empty(cVendedor) .AND. SA3->(DbSeek(xFilial("SA3")+cVendedor))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida a entidadeณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .AND. (nOper <> 5)
	
	lRet := Ft520Valid(@cEntidade,@cCodigo,@cLoja,@aEntDel)	
	
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEfetua a gravacaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet
	
	cFilEnt	:= xFilial(cEntidade)
	
	Begin Transaction
	
	DbSelectArea("ADL")
	DbSetOrder(1)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInclusao/Alteracao de informacoesณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nOper <> 5	
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRemove amarracoes anterioresณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
		ADL->(DbSetOrder(4)) //ADL_FILIAL+ADL_VEND+ADL_FILENT+ADL_ENTIDA+ADL_CODENT+ADL_LOJENT		
		If ADL->(DbSeek(cFilADL+cVendedor+cFilEnt+cEntidade+cCodigo+cLoja))
		
			While !ADL->(Eof()) .AND.;
				ADL->(ADL_FILIAL+ADL_VEND+ADL_FILENT+ADL_ENTIDA+ADL_CODENT+ADL_LOJENT) == (cFilADL+cVendedor+cFilEnt+cEntidade+cCodigo+cLoja)				
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณSo vai remover registros sem oportunidadeณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If Empty(ADL->ADL_CODOPO)
					AAdd(aRecDel,ADL->(Recno()))
				EndIf
				
				ADL->(DbSkip())	 
					
			End
			
			For nX := 1 to Len(aRecDel)
				ADL->(DbGoTo(aRecDel[nX]))
				RecLock("ADL",.F.)
				DbDelete()
				MsUnLock()
			Next nX
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCria ou altera os registrosณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		ADL->(DbSetOrder(1)) //ADL_FILIAL+ADL_CODOPO+ADL_VEND
		lFirstRec :=  !DbSeek(cFilADL+cOportu+cVendedor)
		
		While (!ADL->(Eof())			.AND.;
			ADL->ADL_FILIAL == cFilADL	.AND.;
			ADL->ADL_CODOPO == cOportu	.AND.;
			ADL->ADL_VEND	== cVendedor).OR.;
			lFirstRec
			        
			RecLock("ADL",lFirstRec)
		
			Replace ADL->ADL_FILIAL		With cFilADL
			Replace ADL->ADL_VEND  		With cVendedor
			Replace ADL->ADL_FILENT		With cFilEnt
			Replace ADL->ADL_ENTIDA		With cEntidade
			Replace ADL->ADL_CODENT		With cCodigo
			Replace ADL->ADL_LOJENT		With cLoja
			
			Replace ADL->ADL_CODOPO		With cOportu         			
			
			Replace ADL->ADL_NVLSTR	With SA3->A3_NVLSTR
			
			For nX := SA3->A3_NIVEL to 1 Step -1
				Replace &("ADL_NIVE"+StrZero(nX,2))	 With Left(SA3->A3_NVLSTR,nX*NTAMCOD)
			Next 

			
			Do Case
				Case nOpcao == 2
					Replace ADL->ADL_CODORC		With cChave
				Case nOpcao == 3
					Replace ADL->ADL_CODPRO		With cChave
			EndCase
		
			MsUnLock() 

			If !lFirstRec
				ADL->(DbSkip())
			Else 
				lFirstRec := .F.
				Exit
			EndIf

        End

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRemove os vinculos do vendedor com suspects ou prospectsณ
		//ณque ja viraram prospects ou clientes,nesta ordem.       ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
		Ft520Remov(aEntDel,cVendedor,cEntidade,cCodigo,cLoja)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExclusao de orcamentos, propostas e oportunidadesณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Else

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณDeleta a amarracao do vendedor com a oportunidade/orcamento/proposta ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		ADL->(DbSetOrder(1))

		If ADL->(DbSeek(cFilADL+cOportu))

			RecLock("ADL",.F.)
			DbDelete()
			MsUnLock()

		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMantem o vinculo entre a entidade e o vendedorณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		ADL->(DbSetOrder(4))//ADL_FILIAL+ADL_VEND+ADL_FILENT+ADL_ENTIDA+ADL_CODENT+ADL_LOJENT
		
		If !ADL->(DbSeek(xFilial("ADL")+cVendedor+xFilial(cEntidade)+cEntidade+cLoja))
			Ft520AltEn(	3		, cVendedor	, cEntidade	, cCodigo	,;
			 			cLoja	)
		EndIf

	EndIf
	
	End Transaction
	

EndIf  

RestArea(aAreaSA3)
RestArea(aAreaADL)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt520FimOpบAutor  ณVendas CRM          บ Data ณ  01/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRemove registros do controle de contas apos o encerramento  บฑฑ
ฑฑบ          ณda oportunidade de vendas                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Codigo da oportunidade finalizada                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA520                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft520FimOp(cOport)
Return Nil 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt520FimOrบAutor  ณVendas CRM          บ Data ณ  01/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRemove registros do controle de contas apos o encerramento  บฑฑ
ฑฑบ          ณdo orcamento.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Codigo do orcamento finalizado                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA520                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft520FimOr(cOrcam)

Local aArea	:= GetArea()

DbSelectArea("ADL")
DbSetOrder(2)	//ADL_FILIAL+ADL_CODORC

If DbSeek(xFilial("ADL")+cOrcam)
	
	RecLock("ADL",.F.)
	ADL->ADL_CODORC	:= ""
	MsUnLock()
	
EndIf

RestArea(aArea)

Return Nil 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt520TotalบAutor  ณVendas CRM          บ Data ณ  01/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTotaliza a quantidade de suspects, prospects e clientes paraบฑฑ
ฑฑบ          ณo vendedor informado                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Codigo do vendedor                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA520                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft520Total(cVendedor)
Return Ft520Tota2(cVendedor) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt520LimpaบAutor  ณVendas CRM          บ Data ณ  01/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRemove registros deletados (somente em ambiente SQL).       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpL1 - Indica se todos os registros devem ser apagados(ZAP)บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA520                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft520Limpa(lDelTodos)

Local cQuery	:= ""	// Query enviada ao banco de dados

Default lDelTodos	:= .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณApaga registros deletados quando for utilizado banco de dadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

cQuery	:= "DELETE FROM " + RetSqlName("ADL") 

If !lDelTodos
	
	cQuery	+= " WHERE "

	If TcSrvType() != "AS/400"
		cQuery	+= " D_E_L_E_T_ = '*' "
	Else
		cQuery	+= " @DELETED@ = '*' "
	EndIf

EndIf

TcSqlExec(cQuery)


Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณVendas CRM          บ Data ณ  08/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGeracao do menu funcional                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA520                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()

Local aRotina	:={	{STR0015,"AxPesqui",0,1} ,;		//"Pesquisar"
					{STR0016,"AxVisual",0,2} ,;		//"Visualizar"
					{STR0017,"Ft520Repro",0,3} }	//"Reprocessar"

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt520ValidบAutor  ณVendas CRM          บ Data ณ  15/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a entidade, verificando seus estagios.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Alias da entidade                                   บฑฑ
ฑฑบ          ณExpC2 - Codigo da entidade                                  บฑฑ
ฑฑบ          ณExpC3 - Loja da entidade                                    บฑฑ
ฑฑบ          ณExpC4 - Lista de registros a serem apagados na ADL          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA520                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft520Valid(cEntidade,cCodigo,cLoja,aEntDel)

Local aArea		:= GetArea()			//Armazena o posicionamento atual
Local lRet 		:= .T.					//Retorno da funcao
Local cFilEnt	:= xFilial(cEntidade)	//Filial da entidade validada

DbSelectArea(cEntidade)
DbSetOrder(1)

lRet := DbSeek(cFilEnt+cCodigo+cLoja)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se ha prospect para o suspect selecionadoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (lRet) .AND. (cEntidade == "ACH") .AND. !Empty(ACH->ACH_CODPRO)

	SUS->(DbSetOrder(1)) 

	If SUS->(DbSeek(xFilial("SUS")+ACH->ACH_CODPRO+ACH->ACH_LOJPRO))
	
		cEntidade	:= "SUS"
		cFilEnt		:= xFilial(cEntidade)
		cCodigo		:= ACH->ACH_CODPRO
		cLoja		:= ACH->ACH_LOJPRO
		lRet		:= SUS->(DbSeek(cFilEnt+cCodigo+cLoja))

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณArmazena codigo do suspect para remover vinculo com oณ
		//ณvendedor                                             ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		AAdd(aEntDel,{"ACH",ACH->ACH_CODIGO,ACH->ACH_LOJA})

	EndIf
	
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se ha cliente para o prospect utilizadoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (lRet) .AND. (cEntidade == "SUS") .AND. !Empty(SUS->US_CODCLI)

	SA1->(DbSetOrder(1)) 

	If SA1->(DbSeek(xFilial("SA1")+SUS->US_CODCLI+SUS->US_LOJACLI))

		cEntidade	:= "SA1" 
		cFilEnt		:= xFilial(cEntidade)
		cCodigo		:= SUS->US_CODCLI
		cLoja		:= SUS->US_LOJACLI

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณArmazena codigo do suspect para remover vinculo com oณ
		//ณvendedor                                             ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		AAdd(aEntDel,{"SUS",SUS->US_COD,SUS->US_LOJA})

	EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se ha cliente para o prospect utilizadoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf (lRet) .AND. (cEntidade == "SA1") .AND. !Empty(cCodigo)
	SA1->(DbSetOrder(1)) 
	If SA1->(DbSeek(xFilial("SA1") + cCodigo + cLoja ))
		cEntidade	:= "SA1" 
		cFilEnt		:= xFilial(cEntidade)
	EndIf

ElseIf (lRet) .AND. (cEntidade == "SUS")  

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณArmazena codigo do suspect para remover vinculo com oณ
	//ณvendedor                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ACH->(DbSetOrder(4)) //ACH_FILIAL+ACH_CODPRO+ACH_LOJPRO
	
	If ACH->(DbSeek(xFilial("ACH")+SUS->US_COD+SUS->US_LOJA))
		AAdd(aEntDel,{"ACH",ACH->ACH_CODIGO,ACH->ACH_LOJA})
	EndIf 
	
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt520InEntบAutor  ณVendas CRM          บ Data ณ  15/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณManutencao da amarracao entre entidade e controle de contas บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpN1 - Numero da operacao (3-Inclusao,4-Alteracao,etc.)    บฑฑ
ฑฑบ          ณExpC2 - Codigo do vendedor                                  บฑฑ
ฑฑบ          ณExpC3 - Alias da entidade                                   บฑฑ
ฑฑบ          ณExpC4 - Codigo da entidade                                  บฑฑ
ฑฑบ          ณExpC5 - Loja da entidade                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA520                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft520InEnt(	nOper	, cVendedor	, cEntidade	, cCodigo	,;
		 			  		cLoja	)
		 			  		
Local lRet		:= .T.		 			  		
Local aArea		:= GetArea()
Local aEntDel	:= {} 
Local lNewRec	:= .F.
Local cFilEnt	:= ""
Local nX		:= 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRecupera lista de vendedores ignoradosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cVendIgn == NIL
	cVendIgn	:= SuperGetMv("MV_FATVIGN",,"")
EndIf

If AllTrim(cVendedor) $ cVendIgn
	RestArea(aArea)
	Return lRet
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida o vendedorณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SA3")
DbSetOrder(1)
lRet		:= !Empty(cVendedor) .AND. SA3->(DbSeek(xFilial("SA3")+cVendedor))

If lRet
	
	If nOper <> 5
	
		If Ft520Valid(@cEntidade,@cCodigo,@cLoja,@aEntDel) 
		
			cFilEnt	:= xFilial(cEntidade)
			
			Begin Transaction
		
			DbSelectArea("ADL")
			DbSetOrder(5) //ADL_FILIAL+ADL_FILENT+ADL_ENTIDA+ADL_CODENT+ADL_LOJENT
		
			lNewRec := ADL->(DbSeek(xFilial("ADL")+cFilEnt+cEntidade+cCodigo+cLoja))
			
			RecLock("ADL",!lNewRec)
		
			Replace ADL->ADL_FILIAL		With xFilial("ADL")
			Replace ADL->ADL_VEND  		With cVendedor
			Replace ADL->ADL_FILENT		With cFilEnt
			Replace ADL->ADL_ENTIDA		With cEntidade
			Replace ADL->ADL_CODENT		With cCodigo
			Replace ADL->ADL_LOJENT		With cLoja
			
			Replace ADL->ADL_NVLSTR	With SA3->A3_NVLSTR   

			For nX := SA3->A3_NIVEL to 1 Step -1
				Replace &("ADL_NIVE"+StrZero(nX,2))	 With Left(SA3->A3_NVLSTR,nX*NTAMCOD)
			Next 


			
			MsUnLock()
			
			End Transaction

		EndIf
	
	Else 
		
		DbSelectArea("ADL")
		DbSetOrder(5) //ADL_FILIAL+ADL_FILENT+ADL_ENTIDA+ADL_CODENT+ADL_LOJENT
	
		cFilEnt	:= xFilial(cEntidade)
	
		If ADL->(DbSeek(xFilial("ADL")+cFilEnt+cEntidade+cCodigo+cLoja))
			
			AAdd(aEntDel,{cEntidade,cCodigo,cLoja})
			
		EndIf
		
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRemove os vinculos do vendedor com suspects ou prospectsณ
	//ณque ja viraram prospects ou clientes,nesta ordem.       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	Ft520Remov(aEntDel,cVendedor,cEntidade,cCodigo,cLoja)

Else

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe o vendedor esta em branco, o cadastro teve o codigo do ณ
	//ณvendedor limpo. Neste caso, a amarracao deve ser desfeita.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	cFilEnt	:= xFilial(cEntidade)
	DbSelectArea(cEntidade)
	DbSetOrder(1)
	lRet := DbSeek(cFilEnt+cCodigo+cLoja)
	
	If lRet
	
		DbSelectArea("ADL")
		DbSetOrder(5) //ADL_FILIAL+ADL_FILENT+ADL_ENTIDA+ADL_CODENT+ADL_LOJENT
		
		If ADL->(DbSeek(xFilial("ADL")+cFilEnt+cEntidade+cCodigo+cLoja))
			RecLock("ADL",.F.)
			DbDelete()
			MsUnLock()
		EndIf
		
	EndIf
	
EndIf

//Ft520Limpa()

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt520RemovบAutor  ณVendas CRM          บ Data ณ  15/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza os registros da ADL cuja entidade passou para outroบฑฑ
ฑฑบ          ณestagio.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA520                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft520Remov(aEntDel,cVendedor,cEntidade,cCodigo,cLoja)

Local aArea		:= GetArea()			// Armazena o posicionamento atual
Local aRecEnt	:= {}					// Recnos dos registros de entidades relacionados
Local nX		:= 0					// Auxiliar de loop
Local nY		:= 0					// Auxiliar de loop
Local cFilADL	:= xFilial("ADL") 		// Filial do ADL
Local cFilTmp	:= ""					// Filial da tabela utilizada

ADL->(DbSetOrder(4))	//ADL_FILIAL+ADL_VEND+ADL_FILENT+ADL_ENTIDA+ADL_CODENT+ADL_LOJENT
						
For nX := 1 to Len(aEntDel)       

	cFilTmp	:= xFilial(aEntDel[nX][1])
	
	If ADL->(DbSeek(cFilADL+cVendedor+cFilTmp+aEntDel[nX][1]+aEntDel[nX][2]+aEntDel[nX][3]))
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณArmazena os registros da entidadeณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		While !Eof()					  		.AND.;
			ADL->ADL_FILIAL	== cFilADL	  		.AND.;
			ADL->ADL_VEND	== cVendedor  		.AND.;
			ADL->ADL_FILENT	== cFilTmp	   		.AND.;
			ADL->ADL_ENTIDA	== aEntDel[nX][1]	.AND.; 
			ADL->ADL_CODENT	== aEntDel[nX][2]	.AND.;
			ADL->ADL_LOJENT	== aEntDel[nX][3]
			
			AAdd(aRecEnt,ADL->(Recno()))

			ADL->(DbSkip())

		End 
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณApaga os registros de amarracao ou atualiza os registros    ณ
		//ณonde sao vinculadas as oportunidades, propostas e orcamentosณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nY := 1 to Len(aRecEnt)  
		
			ADL->(DbGoTo(aRecEnt[nY]))
		
			RecLock("ADL",.F.)
		
			If Empty(ADL->(ADL_CODOPO+ADL_CODORC+ADL_CODPRO))
				DbDelete()
			Else
				Replace ADL->ADL_FILENT		With cFilTmp
				Replace ADL->ADL_ENTIDA		With cEntidade
				Replace ADL->ADL_CODENT		With cCodigo
				Replace ADL->ADL_LOJENT		With cLoja
			EndIf
		
			MsUnLock()

		Next nY
		
	EndIf 
	
Next nX

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFT520RpSUSบAutor  ณVendas CRM          บ Data ณ  21/01/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณReprocessa os prospects para criacao do vinculo com os      บฑฑ
ฑฑบ          ณvendedores na tabela ADL                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA520                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft520RpSUS()

Local aArea		:= GetArea()
Local aAreaSUS	:= SUS->(GetArea())
Local aAreaADL	:= ADL->(GetArea())
Local cFilSUS	:= xFilial("SUS")  
Local cAliasSus	:= ""


Local cQuery	:= ""
                                       
cAliasSUS	:= GetNextAlias()

cQuery	:= "SELECT US_FILIAL,US_COD,US_LOJA,US_VEND"
cQuery	+= " FROM " + RetSqlName("SUS")
cQuery	+= " WHERE US_VEND = '" + SA3->A3_COD + "'" 
cQuery	+= " AND US_FILIAL = '" + cFilSUS + "'"
cQuery	+= " AND D_E_L_E_T_ = ''"

cQuery	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSUS,.F.,.T.)
dbGoTop()


While !(cAliasSus)->(Eof()) 				.AND.;
	(cAliasSus)->US_FILIAL	== cFilSUS 		.AND.;
	(cAliasSus)->US_VEND	== SA3->A3_COD
	
	Ft520InEnt(	3	   		   			, SA3->A3_COD		, "SUS"		, (cAliasSus)->US_COD	,;
				(cAliasSus)->US_LOJA	)
				
	(cAliasSus)->(DbSkip())

End

(cAliasSus)->(DbCloseArea())

RestArea(aAreaSUS)
RestArea(aAreaADL)
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFT520RpSUSบAutor  ณVendas CRM          บ Data ณ  21/01/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณReprocessa os prospects para criacao do vinculo com os      บฑฑ
ฑฑบ          ณvendedores na tabela ADL                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA520                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft520RpSA1()

Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaADL	:= ADL->(GetArea())
Local cFilSA1	:= xFilial("SA1")  
Local cAliasSA1	:= ""
Local cQuery	:= ""
                                       
cAliasSA1	:= GetNextAlias()

cQuery	:= "SELECT A1_FILIAL,A1_COD,A1_LOJA,A1_VEND"
cQuery	+= " FROM " + RetSqlName("SA1")
cQuery	+= " WHERE A1_VEND = '" + SA3->A3_COD + "'" 
cQuery	+= " AND A1_FILIAL = '" + cFilSA1 + "'"
cQuery	+= " AND D_E_L_E_T_ = ''"

cQuery	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSA1,.F.,.T.)
dbGoTop()

While !(cAliasSA1)->(Eof()) 				.AND.;
	(cAliasSA1)->A1_FILIAL	== cFilSA1 		.AND.;
	(cAliasSA1)->A1_VEND	== SA3->A3_COD
	
	Ft520InEnt(	3	   		   			, SA3->A3_COD		, "SA1"		, (cAliasSA1)->A1_COD	,;
				(cAliasSA1)->A1_LOJA	)
				
	(cAliasSA1)->(DbSkip())

End


(cAliasSA1)->(DbCloseArea())

RestArea(aAreaSA1)
RestArea(aAreaADL)
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออ"ฑฑ
ฑฑบPrograma  ณFT520AltRvบAutor  ณVendas CRM          บ Data ณ  10/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza a revisao da oportunidade na ADL                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA520                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FT520AltRv(cCodOpor,cRevAtu)
 
Local aArea := GetArea()


Local cQuery := ""
 
cQuery := "UPDATE " + RetSqlName("ADL") + " "
cQuery += "SET ADL_CODOPO = '" +cCodOpor + cRevAtu + "' "
cQuery += " WHERE ADL_CODOPO LIKE ('" + cCodOpor + "%') AND "

If TcSrvType() != "AS/400"
	cQuery += " D_E_L_E_T_ = '' "
Else
	cQuery += " @DELETED@ = '' "
EndIf
 
TcSqlExec(cQuery)
 
 
RestArea(aArea)

Return Nil