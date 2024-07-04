#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA990.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณloja990   บAutor  ณTOTVS               บ Data ณ  12/11/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe o historico de montagens do uMov, ref. a OS          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ uMov                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HisImpUMov(cChave)
Local oList    := Nil //Objeto do Listbox  
Local oDlguMov := Nil //Dialogo principal
Local aDados   := {}  // Contem as montagens importadas do uMov

aDados:= LJCARDADOS(cChave) //Carregar os resgistros das importa็๕es de montagem

If !Empty(aDados)

    DEFINE MSDIALOG oDlguMov TITLE OemToAnsi() FROM 000,000 TO 385,625 PIXEL //"Hist๓rico de montagens."

    @ 005,003 LISTBOX oList FIELDS HEADER ,;                                     
                                      STR0003,;//"Status"
									  STR0004,;//"OS"
									  STR0005,;//"Rev"
									  STR0006,;//"Prod."
                                  	  STR0007,;//"Descri็ใo"
                                   	  STR0008,;//"Dt. Montagem"
									  STR0009,;//"Hr. Montagem"
                                      STR0010,;//"Obs.Montagem"
                                      STR0011,;//"Foto pos montagem"
                                      STR0012,;//"Dt Importa็ใo"
                                      STR0013,;//"Hr Importa็ใo"
                                      STR0014,;//"Dt. Solicita็ใo"
                                      STR0015,;//"Hr. Solicita็ใo"
                                      STR0016 SIZE 308,120 PIXEL //"Usuario"



	oList:SetArray(aDados)
	oList:cToolTip := "Duplo-clique no registro para visualizar a foto p๓s montagem."
	oList:bLine := { || { CorLed(aDados,oList:nAt),aDados[oList:nAt,1],aDados[oList:nAt,2],aDados[oList:nAt,3],aDados[oList:nAt,4],;
	                      aDados[oList:nAt,5],aDados[oList:nAt,6],aDados[oList:nAt,7],aDados[oList:nAt,8],aDados[oList:nAt,9],;
	                      aDados[oList:nAt,10],aDados[oList:nAt,11],aDados[oList:nAt,12],aDados[oList:nAt,13],aDados[oList:nAt,14]}}
	oList:bLDblClick := {|| VerImg(aDados[oList:nAt,9])} 
	oList:GoTop()
	oList:Refresh()
	
	@ 130,010 TO 180,120 Label STR0017 OF oDlguMov PIXEL COLOR CLR_BLUE //Legenda :                 
	
	@ 145,020 BITMAP oBmp2 ResName "BR_VERDE" OF oDlguMov Size 10,10 NoBorder When .F. Pixel 
	@ 145,030 SAY  STR0018 OF oDlguMov PIXEL //"Completa"
	
	@ 155,020 BITMAP oBmp1 ResName "BR_AMARELO" OF oDlguMov Size 10,10 NoBorder When .F. Pixel                                        
	@ 155,030 SAY STR0019 OF oDlguMov PIXEL //"Pendente"
	
	@ 165,020 BITMAP oBmp2 ResName "BR_VERMELHO" OF oDlguMov Size 10,10 NoBorder When .F. Pixel 
	@ 165,030 SAY STR0020  OF oDlguMov PIXEL //"Nใo realizada"
	
	DEFINE SBUTTON oBTN1 FROM 175,250 TYPE 1 ACTION LJGeraTarefauMov(cChave,oList:nAt,aDados,@oList) ENABLE OF oDlguMov PIXEL 
	oBTN1:cCaption := STR0021 //"Tarefa"
	oBTN1:CTOOLTIP := STR0022 //"Selecione um produto com montagem pendente para habilitแ-lo novamente para ser gerado uma nova tarefa de montagem."
	
	DEFINE SBUTTON oBTN2 FROM 175,280 TYPE 1 ACTION oDlguMov:End() ENABLE OF oDlguMov PIXEL
	oBTN2:cCaption := STR0023 //"Fechar"
	
	ACTIVATE MSDIALOG oDlguMov CENTERED
Endif
	
Return(.T.)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณLJCARDADOS    ณAutor  ณTOTVS               ณ Data ณ 12/11/13    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Retorna os valores que serao impressos pelo painel             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ obs.:    ณ Se o atendimento estiver aberto significa que falta montar itemณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function LJCARDADOS(cChave)
Local aArea  	:= GetArea() //salva a area atual
Local aDados    := {} // Contem as montagens importadas do uMov
Local cQuery    := "" // Texto SQL que ้ enviado para o comando TCGenQry
Local cStatus   := "" // Trata a descricao do status da montagem

If  !Empty(AB9->AB9_NUMOS)
	cQuery :=	" SELECT * " +;
			" FROM 	" + RetSqlName("MG4") +;
			" WHERE MG4_FILIAL = '"+alltrim(xFilial("AB9"))+"'"+;
			" AND MG4_NUMLOJ    = '"+alltrim(cChave)+"'"+;
			" AND D_E_L_E_T_ = ''" +;
			" ORDER BY MG4_REV "
 
	cQuery := ChangeQuery(cQuery)
	
	DbSelectArea("MG4")
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRB', .F., .T.)
	
	If !Empty(TRB->(!Eof()))
		While TRB->(!Eof()) 			

			If TRB->MG4_STATUS == "1"    
				cStatus := STR0018//"Completa"
			ElseIf TRB->MG4_STATUS = "2" 
				cStatus := STR0019//"Pendente"
			ElseIf TRB->MG4_STATUS = "3" 
				cStatus :=STR0020//"Nใo realizada"
			Endif	

		   	Aadd(aDados,{ cStatus,;
			    	   	  TRB->MG4_NUMLOJ,;
			    	   	  TRB->MG4_REV,;
			    	   	  TRB->MG4_PRODUT,;
		   	              Posicione("SB1",1,xFilial("SB1")+TRB->MG4_PRODUT,"B1_DESC"),;
		   	              stod(TRB->MG4_DTMONT),;
		   	              TRB->MG4_HRMONT,;
		   	              TRB->MG4_OBSERV,;
		   	              TRB->MG4_FOTO,;
		   	              stod(TRB->MG4_DTPROT),;//Data que foi importado para o Protheus
		   	              TRB->MG4_HRPROT,;//Hora que foi importado para o Protheus
		   	              stod(TRB->MG4_DTSOLI),;
		   	              TRB->MG4_HRSOLI,;
		   	              TRB->MG4_USU})

			TRB->(dbSkip())
		
		EndDo
	Else
      MSGAlert(STR0025,STR0024)//"Nใo existe registro de importa็๕es de montagens."##"Aten็ใo"
    Endif	 
	
	TRB->(DbCloseArea())
	RestArea(aArea)
	
Else
      MSGAlert(STR0025,STR0024)//"Nใo existe registro de importa็๕es de montagens."##"Aten็ใo"
Endif

Return aDados

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณloja990 บAutor  ณTOTVS	     บ Data ณ  12/11/2013         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Led dos status das montagens                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe	 ณ CorLed(aDados)				              				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณ aDados - posicao na linha    			                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Loja                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CorLed(aDados,nAt)
Local oLed    	:= "" //Objeto principal de retorno
Local oVerde  	:= LoaDbitmap(GetResources(),"BR_VERDE")   //carrega a imagem do reposit๓rio no objeto	
Local oAmarelo  := LoaDbitmap(GetResources(),"BR_AMARELO") //carrega a imagem do reposit๓rio no objeto
Local oVermelho := LoaDbitmap(GetResources(),"BR_VERMELHO")//carrega a imagem do reposit๓rio no objeto

If !Empty(aDados)
	If alltrim(aDados[nAt,1]) == STR0018//"Completa"
		oLed:= oVerde
	Else
		If alltrim(aDados[nAt,1]) == STR0019//"Pendente"
			oLed:= oAmarelo
		Else
			oLed:= oVermelho //"Nใo realizada"
		Endif	
	Endif			
Endif
			
Return(oLed)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณloja990 บAutor  ณTOTVS	     บ Data ณ  18/11/2013         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Led dos status das montagens                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe	 ณ VerImg(aDados)				              				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณ cEndereco - endereco url da foto 		                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออoอออออออออออนฑฑ
ฑฑบUso       ณ Loja                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VerImg(cEndereco)
Local oDlg       := Nil  //Objeto principal
Local oTIBrowser := Nil  //Cria um objeto do tipo pแgina de internet.
Local aSize      := MsAdvSize()// Size da Dialog - Funcao de calculo para coordenadas de tela.
Local cUrl       := cEndereco // endereco da foto

// Atualiza as corrdenadas da Janela MAIN
oMainWnd:CoorsUpdate()
nMyWidth  := oMainWnd:nClientWidth - 10
nMyHeight := oMainWnd:nClientHeight - 30
 
If !Empty(cUrl)
  DEFINE DIALOG oDlg TITLE STR0026 From aSize[7],00 To nMyHeight,nMyWidth PIXEL//"Foto"
  oTIBrowser := TIBrowser():New(07,07,nMyHeight-220, nMyWidth-820,cUrl,oDlg)
  oTIBrowser:GoHome()

  ACTIVATE DIALOG oDlg CENTERED 

Else
   MsgAlert(STR0027)//"Nใo foi inserida nenhuma imagem para essa montagem!"
EndIf

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณloja990 บAutor  ณTOTVS              บ Data ณ  19/11/2013    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Zera a data e a hora do SL1 e dos itens do SL2 para gerar  บฑฑ
ฑฑบ          ณ novamente um tarefa no umov                                บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe	 ณ LJGeraTarefauMov(aDados)			          				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณ aDados - posicao na linha    			                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Loja                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJGeraTarefauMov(cChave,nAt,aDados,oList)                                                                                             
Local lOk  := .F. //controla a atualizacao da SL1
Local nRev := 0   //controla a revisใo do atendimento que esta sendo solicitada

If alltrim(aDados[nAt,1]) <> STR0018 //"Completa" - so podera gerar uma nova tarefa se o status do item for diferente de completa
	DbSelectArea("SL2")
	SL2->(DbSetOrder(1))//L2_FILIAL+L2_NUM                                                                                                                            
	If SL2->(DbSeek(xFilial("SL2")+alltrim(cChave)))
		While SL2->(!Eof()) .And. (SL2->L2_FILIAL+SL2->L2_NUM) == (xFilial("SL2")+alltrim(cChave))
			If alltrim(SL2->L2_PRODUTO) == alltrim(aDados[nAt,4])
				RecLock("SL2",.F.)
				SL2->L2_DTUMOV := Ctod("  /  /  ","DDMMYY")
				SL2->L2_HRUMOV := ""
				SL2->(MsUnlock())	    				
			Endif	
			SL2->(dbSkip())
		Enddo	
		If lOk 
			MsgAlert(STR0028,STR0024)//"Solicita็ใo gerada com sucesso!"##"Aten็ใo"
			lOk  := .F.
		Else
			MsgAlert(STR0028,STR0024)//"Solicita็ใo gerada com sucesso!"##"Aten็ใo"
			lOk  := .F.			
		Endif
			
   
		//Atualizacao da data e hora que foi solicitada uma nova tarefa de montagem no uMov
		DbSelectArea("MG4")                                                    
		MG4->(dbGoTop())
		MG4->(DbSetOrder(1))//MG4_FILIAL+MG4_NUMLOJ+MG4_PRODUT+MG4_REV     
		nRev :=  PadL(alltrim(str(aDados[nAt,3])),2)
		If MG4->(DbSeek(xFilial("AB9")+alltrim(cChave)))
			While MG4->(!Eof()) .And. (MG4->MG4_FILIAL+alltrim(MG4->MG4_NUMLOJ)) == (xFilial("MG4")+alltrim(cChave))
				If alltrim(MG4->MG4_PRODUT) == alltrim(aDados[nAt,4]) .And. alltrim(str(MG4->MG4_REV)) == alltrim(nRev)
					RecLock("MG4",.F.)
					MG4->MG4_DTSOLI := dDataBase
					MG4->MG4_HRSOLI := SubStr( StrTran(Time(),":",""),1,2)+":"+SubStr( StrTran(Time(),":",""),3,2)
					MG4->MG4_USU    := cUserName
					MG4->(MsUnlock())           
					aDados[nAt,12] :=  dDataBase
					aDados[nAt,13] :=  SubStr( StrTran(Time(),":",""),1,2)+":"+SubStr( StrTran(Time(),":",""),3,2)
					aDados[nAt,14] := cUserName
				Endif
				MG4->(dbSkip())		
			EndDo	
		Endif
	
		LJCARDADOS(cChave)
		oList:SetArray(aDados)
		oList:bLine := { || { CorLed(aDados,oList:nAt),aDados[oList:nAt,1],aDados[oList:nAt,2],aDados[oList:nAt,3],aDados[oList:nAt,4],;
	                      aDados[oList:nAt,5],aDados[oList:nAt,6],aDados[oList:nAt,7],aDados[oList:nAt,8],aDados[oList:nAt,9],;
	                      aDados[oList:nAt,10],aDados[oList:nAt,11],aDados[oList:nAt,12],aDados[oList:nAt,13],aDados[oList:nAt,14]}}
		oList:GoTop()
		oList:Refresh()
	Endif	
Else
	MsgAlert(STR0029,STR0024)//"O status desse item esta completo!"##"Aten็ใo"
Endif

Return Nil
