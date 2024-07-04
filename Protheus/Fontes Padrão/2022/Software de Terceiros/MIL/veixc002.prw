// ษออออออออหออออออออป
// บ Versao บ 14     บ
// ศออออออออสออออออออผ

#Include "PROTHEUS.CH"
#Include "VEIXC002.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ VEIXC002 บ Autor ณ Andre Luis Almeida บ Data ณ  29/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Tela Consulta - Visualiza Cliente / Veiculo / Atendimentos บฑฑ
ฑฑบ          ณ e Inicializa Atendimento pela Oportunidade de Negocios     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aRecInter = RecNo dos Interesses da Oportunidade de Vendas บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ aRetVV9                                                    บฑฑ
ฑฑบ          ณ aRetVV9[1] = .t. (OK na Janela) / .f. (Calcelou Janela)    บฑฑ
ฑฑบ          ณ aRetVV9[2] = Codigo do Cliente                             บฑฑ
ฑฑบ          ณ aRetVV9[3] = Loja do Cliente                               บฑฑ
ฑฑบ          ณ aRetVV9[4] = Nome do Cliente                               บฑฑ
ฑฑบ          ณ aRetVV9[5] = Fone do Cliente                               บฑฑ
ฑฑบ          ณ aRetVV9[6] = Vetor com os interesses do cliente (aRetOport)บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Veiculos                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIXC002(aRecInter)
Local lTelaInc    := .t.
Local lOportun    := .f.
Local aRetVV9     := {}
Local aRetOport   := {}
Local aObjects    := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {} 
Local aSizeAut    := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor     := 0  
Local nTam        := 0
Local lVAI_VTLIAT := ( VAI->(FieldPos("VAI_VTLIAT")) > 0 )
Local lVAI_VABAON := ( VAI->(FieldPos("VAI_VABAON")) > 0 )
Private cVV9CCli  := space(TamSx3("VV9_CODCLI")[1])
Private cVV9LCli  := space(TamSx3("VV9_LOJA")[1])
Private cVV9NCli  := space(TamSx3("VV9_NOMVIS")[1])
Private cVV9FCli  := space(TamSx3("VV9_TELVIS")[1])
Private cVV9ECli  := space(TamSx3("A1_EMAIL")[1])
Private lAllLoja  := .f.
Private M->VDM_CAMPOP := space(TamSX3("VDM_CAMPOP")[1]) // SXB - VX5
Private cFilCodMar    := space(TamSx3("VDM_CODMAR")[1]) // SXB - VV2
Private cVDMCMod  := space(TamSx3("VDM_MODVEI")[1])
Private cVDMCCor  := space(TamSx3("VDM_CORVEI")[1])
Private dVDMDInt  := dDataBase
Private o_Verd    := LoadBitmap( GetResources() , "BR_VERDE" )
Private o_Ocea    := LoadBitmap( GetResources() , "lbok_ocean" )
Private o_Pret    := LoadBitmap( GetResources() , "BR_PRETO" )
Private o_Amar    := LoadBitmap( GetResources() , "BR_AMARELO" )
Private o_Lara    := LoadBitmap( GetResources() , "BR_LARANJA" )
Private o_Bran    := LoadBitmap( GetResources() , "BR_BRANCO" )
Private o_Azul    := LoadBitmap( GetResources() , "BR_AZUL" )
Private o_Verm    := LoadBitmap( GetResources() , "BR_VERMELHO" )
Private oOkTik    := LoadBitmap( GetResources() , "LBTIK" )
Private oNoTik    := LoadBitmap( GetResources() , "LBNO" )
Private aVerAtend := {} 
Private aVerOport := {} 
Private cOrdVet   := "0C"
Default aRecInter := {} // RecNo's dos Interesses da Oportunidade de Vendas
If len(aRecInter) == 0
	VAI->(DbSetOrder(4))
	VAI->(DbSeek(xFilial("VAI")+__cUserID))
	If lVAI_VTLIAT .and. VAI->VAI_VTLIAT $ " 12" // 1=Consulta e Inclui / 2=Consulta e Inclui somente com Op.Negocios
		lTelaInc := .f.
		// Configura os tamanhos dos objetos
		aObjects := {}
		AAdd( aObjects, { 05, 34, .T. , .F. } )  	// Label Superior
		AAdd( aObjects, { 01, 10, .T. , .T. } )  	// Listbox 
		// Fator de reducao de 90%
		For nCntFor := 1 to Len(aSizeAut)
			aSizeAut[nCntFor] := INT(aSizeAut[nCntFor] * 0.90)
		Next   
		aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
		aPosObj := MsObjSize (aInfo, aObjects,.F.)    
	    //
		FS_LEVATEND(0)
		//
		DbSelectArea("VV9")
		DEFINE MSDIALOG oV011Inc TITLE STR0001 From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] of oMainWnd STYLE DS_MODALFRAME STATUS PIXEL // Atendimento de Venda
			oV011Inc:lEscClose := .F.
	        //
			oFoldVXC02 := TFolder():New(aPosObj[2,1],aPosObj[2,2]+1,{STR0022,STR0023},{},oV011Inc,,,,.t.,.f.,aPosObj[2,4]-1,aPosObj[2,3]-aPosObj[2,1]-1) // Atendimentos / Oportunidade de Negocios
			oFoldVXC02:bChange := {|| IIf(oFoldVXC02:nOption==1,.t.,oLbVerOpo:SetFocus()) }
			//
			nTam := ( aPosObj[2,4] / 5 ) //variavel que armazena o resutlado da divisao da tela.                        
	        //
			@ aPosObj[1,1]+000,aPosObj[1,2]+002 TO aPosObj[1,3],aPosObj[1,4] LABEL (" "+STR0002+" ") OF oV011Inc PIXEL // Filtro Cliente
			@ aPosObj[1,1]+010,aPosObj[1,2]+012 SAY (STR0003+":") SIZE 30,10 OF oV011Inc PIXEL COLOR CLR_BLUE // Cliente
			@ aPosObj[1,1]+008,aPosObj[1,2]+042 MSGET oVV9CCli VAR cVV9CCli VALID FS_LEVANTA(1) PICTURE "@!" F3 "SA1" SIZE 37,8 OF oV011Inc PIXEL COLOR CLR_BLUE HASBUTTON 
			@ aPosObj[1,1]+008,aPosObj[1,2]+080 MSGET oVV9LCli VAR cVV9LCli VALID FS_LEVANTA(1) PICTURE "@!" SIZE 15,8 OF oV011Inc PIXEL COLOR CLR_BLUE
			@ aPosObj[1,1]+010,aPosObj[1,2]+112 SAY (STR0004+":") SIZE 30,10 OF oV011Inc PIXEL COLOR CLR_BLUE // Nome
			@ aPosObj[1,1]+008,aPosObj[1,2]+142 MSGET oVV9NCli VAR cVV9NCli VALID FS_LEVANTA(2) PICTURE "@!" SIZE 145,8 OF oV011Inc PIXEL COLOR CLR_BLUE
			@ aPosObj[1,1]+022,aPosObj[1,2]+012 SAY (STR0005+":") SIZE 30,10 OF oV011Inc PIXEL COLOR CLR_BLUE // Telefone
			@ aPosObj[1,1]+020,aPosObj[1,2]+042 MSGET oVV9FCli VAR cVV9FCli VALID FS_LEVANTA(3) PICTURE "@!" SIZE 53,8 OF oV011Inc PIXEL COLOR CLR_BLUE
			@ aPosObj[1,1]+022,aPosObj[1,2]+112 SAY (STR0006+":") SIZE 30,10 OF oV011Inc PIXEL COLOR CLR_BLUE // E-mail
			@ aPosObj[1,1]+020,aPosObj[1,2]+142 MSGET oVV9ECli VAR cVV9ECli VALID FS_LEVANTA(4) PICTURE "@!" SIZE 145,8 OF oV011Inc PIXEL COLOR CLR_BLUE
			@ aPosObj[1,1]+010,aPosObj[1,2]+290 CHECKBOX oAllLoja VAR lAllLoja PROMPT STR0035 OF oV011Inc ON CLICK FS_LEVANTA(1) SIZE 125,08 PIXEL // "Todas as Lojas"
			@ aPosObj[1,1]+007,aPosObj[1,4]-062 BUTTON oBotLimp PROMPT STR0033 OF oV011Inc SIZE 55,11 PIXEL ACTION FS_LIMPAR() // Limpar Filtro Cliente
			@ aPosObj[1,1]+020,aPosObj[1,4]-062 BUTTON oBotSair PROMPT STR0018 OF oV011Inc SIZE 55,11 PIXEL ACTION oV011Inc:End() // SAIR
			//
			// Folder 1
			//
			@ 001,001 LISTBOX oLbVerAte FIELDS HEADER (""),;
				STR0007,; // Filial
				STR0036,; // Cli. Loja
				STR0008,; // Data
				STR0009,; // Atendimento
				STR0010,; // Nro NF
				STR0011,; // Serie
				STR0012;  // Valor        
				COLSIZES 10,80,30,45,50,45,30,50 SIZE aPosObj[2,4]-5,aPosObj[2,3]-aPosObj[1,3]-45 OF oFoldVXC02:aDialogs[1] PIXEL ON CHANGE FS_TXTBOTAO(aVerAtend[oLbVerAte:nAt,05]) ON DBLCLICK IIf(!Empty(aVerAtend[oLbVerAte:nAt,1]),(VV9->(DbSeek(aVerAtend[oLbVerAte:nAt,1])),oV011Inc:End()),.t.)
				oLbVerAte:SetArray(aVerAtend)
				oLbVerAte:bLine := { || {	IIf(aVerAtend[oLbVerAte:nAt,02]=="A",o_Verd,IIf(aVerAtend[oLbVerAte:nAt,02]=="X",o_Ocea,IIf(aVerAtend[oLbVerAte:nAt,02]$"F.T",o_Pret,IIf(aVerAtend[oLbVerAte:nAt,02]=="P",o_Amar,IIf(aVerAtend[oLbVerAte:nAt,02]=="R",o_Lara,IIf(aVerAtend[oLbVerAte:nAt,02]=="O",o_Bran,IIf(aVerAtend[oLbVerAte:nAt,02]=="L",o_Azul,o_Verm))))))),;
											aVerAtend[oLbVerAte:nAt,03],;
											aVerAtend[oLbVerAte:nAt,09],;
											Transform(aVerAtend[oLbVerAte:nAt,04],"@D"),;
											aVerAtend[oLbVerAte:nAt,05],;
											aVerAtend[oLbVerAte:nAt,07],;
											aVerAtend[oLbVerAte:nAt,08],;
											FG_AlinVlrs(Transform(aVerAtend[oLbVerAte:nAt,06],"@E 999,999,999.99")) }}
			//
			@ aPosObj[2,3]-aPosObj[1,3]-043,000+(nTam*0)+03 TO aPosObj[2,3]-aPosObj[1,3]-020,(nTam*4)-1 LABEL (" "+STR0013+" ") OF oFoldVXC02:aDialogs[1] PIXEL  // Visualizar
			@ aPosObj[2,3]-aPosObj[1,3]-035,003+(nTam*0)+((((nTam*1)-(nTam*0))-60)/2) BUTTON oBotVisu PROMPT STR0009 OF oFoldVXC02:aDialogs[1] SIZE 70,11 PIXEL ACTION FS_VERATEND(aVerAtend[oLbVerAte:nAt,1]) WHEN !Empty(aVerAtend[oLbVerAte:nAt,1]) // Atendimento
			@ aPosObj[2,3]-aPosObj[1,3]-035,005+(nTam*1)+((((nTam*2)-(nTam*1))-65)/2) BUTTON oBotOSrv PROMPT STR0014 OF oFoldVXC02:aDialogs[1] SIZE 65,11 PIXEL ACTION FG_SALDOS(cVV9CCli,cVV9LCli,"","") WHEN !Empty(cVV9CCli+cVV9LCli) // OS(s) do Cliente
			@ aPosObj[2,3]-aPosObj[1,3]-035,002+(nTam*2)+((((nTam*3)-(nTam*2))-65)/2) BUTTON oBotVCli PROMPT STR0015 OF oFoldVXC02:aDialogs[1] SIZE 65,11 PIXEL ACTION VEIVC090(cVV9CCli,cVV9LCli,.t.) WHEN !Empty(cVV9CCli+cVV9LCli) // Veiculos do Cliente
			@ aPosObj[2,3]-aPosObj[1,3]-035,000+(nTam*3)+((((nTam*4)-(nTam*3))-65)/2) BUTTON oBotCCEV PROMPT STR0016 OF oFoldVXC02:aDialogs[1] SIZE 65,11 PIXEL ACTION VEICC500(cVV9CCli,cVV9LCli) WHEN !Empty(cVV9CCli+cVV9LCli) // Contatos CEV do Cliente
			//
			@ aPosObj[2,3]-aPosObj[1,3]-043,000+(nTam*4)+02 TO aPosObj[2,3]-aPosObj[1,3]-020,(nTam*5)-6 LABEL (" "+STR0019+" ") OF oFoldVXC02:aDialogs[1] PIXEL  // Incluir
			@ aPosObj[2,3]-aPosObj[1,3]-035,000+(nTam*4)+((((nTam*5)-(nTam*4))-60)/2) BUTTON oBotIncl1 PROMPT STR0017 OF oFoldVXC02:aDialogs[1] SIZE 60,11 PIXEL ACTION IIf(FS_VALIDOK(),(lTelaInc:=.t.,oV011Inc:End()),.t.) // Novo Atendimento
			//
			// Folder 2
			//
			@ 001,001 LISTBOX oLbVerOpo FIELDS HEADER (""),;
				STR0025,; // Campanha
				STR0026,; // Marca
				STR0027,; // Modelo
				STR0028,; // Cor
				STR0039,; // Opcionais
				STR0029,; // Qtd.
				STR0030,; // Data Interesse
				STR0031,; // Data Limite
				STR0032; // Cliente
				COLSIZES 10,50,25,70,50,70,30,43,43,140 SIZE aPosObj[2,4]-5,aPosObj[2,3]-aPosObj[1,3]-45 OF oFoldVXC02:aDialogs[2] PIXEL ON DBLCLICK FS_VXC002DBL(oLbVerOpo:nAt)
				oLbVerOpo:SetArray(aVerOport)
				oLbVerOpo:bLine := { || {	IIf(aVerOport[oLbVerOpo:nAt,01],oOkTik,oNoTik) ,;
									aVerOport[oLbVerOpo:nAt,02] ,;
									aVerOport[oLbVerOpo:nAt,03],aVerOport[oLbVerOpo:nAt,04],aVerOport[oLbVerOpo:nAt,05] ,;
									aVerOport[oLbVerOpo:nAt,13] ,;
									FG_AlinVlrs(Transform(aVerOport[oLbVerOpo:nAt,06],"@E 999,999")) ,;
									Transform(aVerOport[oLbVerOpo:nAt,07],"@D") ,;
									Transform(aVerOport[oLbVerOpo:nAt,08],"@D") ,;
									aVerOport[oLbVerOpo:nAt,09]+"-"+aVerOport[oLbVerOpo:nAt,10]+" "+aVerOport[oLbVerOpo:nAt,11] }}
				oLbVerOpo:bHeaderClick := {|oObj,nCol| FS_ORDVET(nCol) , }
			//
			@ aPosObj[2,3]-aPosObj[1,3]-040,000+(nTam*0)+03 TO aPosObj[2,3]-aPosObj[1,3]-020,(nTam*4)-1 LABEL "" OF oFoldVXC02:aDialogs[2] PIXEL
			@ aPosObj[2,3]-aPosObj[1,3]-040,006 SAY (STR0025) SIZE 30,10 OF oFoldVXC02:aDialogs[2] PIXEL COLOR CLR_BLUE // Campanha
			@ aPosObj[2,3]-aPosObj[1,3]-033,006 MSGET oVDMCamp VAR M->VDM_CAMPOP PICTURE "@!" F3 "VX5" SIZE 033,8 OF oFoldVXC02:aDialogs[2] PIXEL COLOR CLR_BLUE HASBUTTON
			@ aPosObj[2,3]-aPosObj[1,3]-040,042 SAY (STR0026) SIZE 30,10 OF oFoldVXC02:aDialogs[2] PIXEL COLOR CLR_BLUE // Marca
			@ aPosObj[2,3]-aPosObj[1,3]-033,042 MSGET oVDMCMar VAR cFilCodMar PICTURE "@!" F3 "VE1" SIZE 028,8 OF oFoldVXC02:aDialogs[2] PIXEL COLOR CLR_BLUE HASBUTTON
			@ aPosObj[2,3]-aPosObj[1,3]-040,074 SAY (STR0027) SIZE 30,10 OF oFoldVXC02:aDialogs[2] PIXEL COLOR CLR_BLUE // Modelo
			@ aPosObj[2,3]-aPosObj[1,3]-033,074 MSGET oVDMCMod VAR cVDMCMod PICTURE "@!" F3 "VV2SQL" SIZE 108,8 OF oFoldVXC02:aDialogs[2] PIXEL COLOR CLR_BLUE HASBUTTON
			@ aPosObj[2,3]-aPosObj[1,3]-040,182 SAY (STR0028) SIZE 30,10 OF oFoldVXC02:aDialogs[2] PIXEL COLOR CLR_BLUE // Cor
			@ aPosObj[2,3]-aPosObj[1,3]-033,182 MSGET oVDMCCor VAR cVDMCCor PICTURE "@!" F3 "VVC" SIZE 038,8 OF oFoldVXC02:aDialogs[2] PIXEL COLOR CLR_BLUE HASBUTTON
			@ aPosObj[2,3]-aPosObj[1,3]-040,221 SAY (STR0030) SIZE 40,10 OF oFoldVXC02:aDialogs[2] PIXEL COLOR CLR_BLUE // Data Interesse
			@ aPosObj[2,3]-aPosObj[1,3]-033,221 MSGET oVDMDInt VAR dVDMDInt PICTURE "@D" SIZE 045,8 OF oFoldVXC02:aDialogs[2] PIXEL COLOR CLR_BLUE HASBUTTON
			@ aPosObj[2,3]-aPosObj[1,3]-035,270 BUTTON oBotFilt2 PROMPT STR0034 OF oFoldVXC02:aDialogs[2] SIZE 30,10 PIXEL ACTION FS_LEVOPORT(1) // Filtrar
			//
			@ aPosObj[2,3]-aPosObj[1,3]-043,000+(nTam*4)+02 TO aPosObj[2,3]-aPosObj[1,3]-020,(nTam*5)-6 LABEL (" "+STR0024+" ") OF oFoldVXC02:aDialogs[2] PIXEL  // Incluir com Interesses
			@ aPosObj[2,3]-aPosObj[1,3]-035,000+(nTam*4)+((((nTam*5)-(nTam*4))-60)/2) BUTTON oBotIncl2 PROMPT STR0017 OF oFoldVXC02:aDialogs[2] SIZE 60,11 PIXEL ACTION IIf(FS_VALIDOK(),(lTelaInc:=.t.,lOportun:=.t.,oV011Inc:End()),.t.) // Novo Atendimento
			//
			If lVAI_VABAON
				If VAI->VAI_VABAON == "0" // 0=Nao Visualizar
					oFoldVXC02:HidePage(2) // Ocultar Folder 2 - Oportunidade de Negocios
				EndIf
			EndIf
	        //
		ACTIVATE MSDIALOG oV011Inc CENTER
	EndIf
	For nCntFor := 1 to len(aVerOport)
		If aVerOport[nCntFor,1] // Selecionado
			VV2->(DbSetOrder(1))
			VV2->(DbSeek(xFilial("VV2")+aVerOport[nCntFor,3]+aVerOport[nCntFor,4]))
			aAdd(aRetOport,{aVerOport[nCntFor,3],VV2->VV2_GRUMOD,aVerOport[nCntFor,4],aVerOport[nCntFor,5],aVerOport[nCntFor,12],lAllLoja,aVerOport[nCntFor,13]})
		EndIf
	Next
Else
	lTelaInc := .t.
	For nCntFor := 1 to len(aRecInter)
		VDM->(DbGoTo(aRecInter[nCntFor]))
		If Empty(cVV9CCli)
			VDL->(DbSetOrder(1)) // VDL_FILIAL + VDL_CODOPO
			If VDL->(DbSeek( VDM->VDM_FILIAL + VDM->VDM_CODOPO ))
				cVV9CCli := VDL->VDL_CODCLI
				cVV9LCli := VDL->VDL_LOJCLI
				cVV9NCli := VDL->VDL_NOMCLI
				cVV9FCli := VDL->VDL_TELCLI
	        EndIf
        EndIf
		VV2->(DbSetOrder(1))
		VV2->(DbSeek(xFilial("VV2")+VDM->VDM_CODMAR+VDM->VDM_MODVEI))
		aAdd(aRetOport,{VDM->VDM_CODMAR,VV2->VV2_GRUMOD,VDM->VDM_MODVEI,VDM->VDM_CORVEI,VDM->(RecNo()),.f.,VDM->VDM_OPCFAB})
	Next
EndIf
aRetVV9 := {lTelaInc,cVV9CCli,cVV9LCli,cVV9NCli,cVV9FCli,aRetOport}
Return(aRetVV9)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_VALIDOKบ Autor ณ Andre Luis Almeida บ Data ณ  03/12/13  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao do OK                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VALIDOK()
Local lRet        := .t.
Local nCntFor     := 0
Local lVAI_VTLIAT := ( VAI->(FieldPos("VAI_VTLIAT")) > 0 )
If lVAI_VTLIAT .and. VAI->VAI_VTLIAT == "2" // 2=Visualiza e Inclui somente com Oportunidade de Negocios
	lRet := .f.
	For nCntFor := 1 to len(aVerOport)
		If aVerOport[nCntFor,1] // Selecionado
        	lRet := .t.
        	Exit
		EndIf
	Next
	If !lRet
		MsgStop(STR0037,STR0038) // Necessario selecionar Interesse(s) na pasta Oportunidade de Negocios. Impossivel continuar! / Atencao
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VERATENDบ Autor ณ Andre Luis Almeida บ Data ณ  29/03/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Visualiza o Atendimento                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VERATEND(cAte)
DbSelectArea("VV9")
DbSetOrder(1)
If DbSeek( cAte )
	VEIXX002(NIL,NIL,NIL,2,) // Visualizar
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TXTBOTAOบ Autor ณ Andre Luis Almeida บ Data ณ  29/03/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza TEXTO do Botao Visualiza Atendimento              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TXTBOTAO(cAte) // Atualiza TEXTO do Botao Visualiza Atendimento
	oBotVisu:cCaption := STR0009+" "+cAte // Atendimento
	oBotVisu:Refresh()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_LEVATENDบ Autor ณ Andre Luis Almeida บ Data ณ  29/03/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Levanta Atendimentos                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_LEVATEND(nTip)
Local nCont       := 0
Local cBkpFilAnt  := cFilAnt
Local aFilAtu     := FWArrFilAtu()
Local aSM0        := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cQuery      := ""
Local cQALVV0     := "SQLVV90A"
Local cVV9_STATUS := ""
Local cFilNroAte  := ""
//
aVerAtend := {}
//
If !Empty(cVV9CCli+cVV9LCli) // Levanta todos atendimentos do Cliente/Loja

	For nCont := 1 to Len(aSM0)

		cFilAnt := aSM0[nCont]

		cQuery := "SELECT VV9.VV9_FILIAL , VV9.VV9_NUMATE , VV9.VV9_STATUS , VV9.VV9_DATVIS , VV9.VV9_LOJA , VV0.VV0_NUMNFI , VV0.VV0_SERNFI , VV0.VV0_VALMOV , VVA.VVA_CHAINT "
		cQuery += "FROM "+RetSqlName("VV9")+" VV9 "
		cQuery += "INNER JOIN "+RetSqlName("VV0")+" VV0 ON ( VV0.VV0_FILIAL=VV9.VV9_FILIAL AND VV0.VV0_NUMTRA=VV9.VV9_NUMATE AND VV0.D_E_L_E_T_=' ' ) "
		cQuery += "INNER JOIN "+RetSqlName("VVA")+" VVA ON ( VVA.VVA_FILIAL=VV9.VV9_FILIAL AND VVA.VVA_NUMTRA=VV9.VV9_NUMATE AND VVA.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE VV9.VV9_FILIAL='"+xFilial("VV9")+"' AND VV9.VV9_CODCLI='"+cVV9CCli+"' AND "
		If !lAllLoja
			cQuery += "VV9.VV9_LOJA='"+cVV9LCli+"' AND "
		EndIf
		If Empty(VAI->VAI_ATEOUT) .or. VAI->VAI_ATEOUT == "0" // Nao Visualiza Atendimentos de outros vendedores
			cQuery += "VV0.VV0_CODVEN='"+VAI->VAI_CODVEN+"' AND "
		EndIf
		cQuery += "VV9.D_E_L_E_T_=' ' ORDER BY VV9.VV9_FILIAL , VV9.VV9_NUMATE , VV9.VV9_DATVIS "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV0, .F., .T. )
		Do While !( cQAlVV0 )->( Eof() )
			If ( cQAlVV0 )->( VV9_FILIAL ) + ( cQAlVV0 )->( VV9_NUMATE ) == cFilNroAte
				cFilNroAte := ( cQAlVV0 )->( VV9_FILIAL ) + ( cQAlVV0 )->( VV9_NUMATE )
				( cQAlVV0 )->( DbSkip() )
				Loop
			EndIf
			cVV9_STATUS := ( cQAlVV0 )->( VV9_STATUS )
			If cVV9_STATUS == "A"
				VV1->(DbSetOrder(1))
				VV1->(DbSeek( xFilial("VV1") + ( cQAlVV0 )->( VVA_CHAINT ) ))
				If VV1->VV1_SITVEI == "1" // 1-Vendido
					cVV9_STATUS := "X"
				EndIf
			EndIf
			ni := aScan(aVerAtend, {|x| x[1] == ( cQAlVV0 )->( VV9_FILIAL )+( cQAlVV0 )->( VV9_NUMATE ) } )
			If ni > 0
				If cVV9_STATUS == "X"
					aVerAtend[ni,2] := cVV9_STATUS
				EndIf
			Else			
				aAdd(aVerAtend,{ ( cQAlVV0 )->( VV9_FILIAL )+( cQAlVV0 )->( VV9_NUMATE ) , cVV9_STATUS , ( cQAlVV0 )->( VV9_FILIAL )+"-"+left(FWFilialName(),15) , stod(( cQAlVV0 )->( VV9_DATVIS )) , ( cQAlVV0 )->( VV9_NUMATE ) , ( cQAlVV0 )->( VV0_VALMOV ) , ( cQAlVV0 )->( VV0_NUMNFI ) , FGX_UFSNF(( cQAlVV0 )->( VV0_SERNFI )) , ( cQAlVV0 )->( VV9_LOJA ) })
			EndIf
			( cQAlVV0 )->( DbSkip() )
		EndDo
		( cQAlVV0 )->( dbCloseArea() )

	Next
	cFilAnt := cBkpFilAnt
	
EndIf
If len(aVerAtend) <= 0
	aAdd(aVerAtend,{ "" , "" , "" , ctod("") , "" , 0 , "" , "" , "" })
EndIf
If nTip > 0  
	oLbVerAte:nAt := 1
	oLbVerAte:SetArray(aVerAtend)
	oLbVerAte:bLine := { || {	IIf(aVerAtend[oLbVerAte:nAt,02]=="A",o_Verd,IIf(aVerAtend[oLbVerAte:nAt,02]=="X",o_Ocea,IIf(aVerAtend[oLbVerAte:nAt,02]$"F.T",o_Pret,IIf(aVerAtend[oLbVerAte:nAt,02]=="P",o_Amar,IIf(aVerAtend[oLbVerAte:nAt,02]=="R",o_Lara,IIf(aVerAtend[oLbVerAte:nAt,02]=="O",o_Bran,IIf(aVerAtend[oLbVerAte:nAt,02]=="L",o_Azul,o_Verm))))))),;
								aVerAtend[oLbVerAte:nAt,03],;
								aVerAtend[oLbVerAte:nAt,09],;
								Transform(aVerAtend[oLbVerAte:nAt,04],"@D"),;
								aVerAtend[oLbVerAte:nAt,05],;
								aVerAtend[oLbVerAte:nAt,07],;
								aVerAtend[oLbVerAte:nAt,08],;
								FG_AlinVlrs(Transform(aVerAtend[oLbVerAte:nAt,06],"@E 999,999,999.99")) }}
	oLbVerAte:SetFocus()
	oBotIncl1:SetFocus()
	oLbVerAte:Refresh()
EndIf
//
FS_LEVOPORT(nTip)
//
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_LEVOPORTบ Autor ณ Andre Luis Almeida บ Data ณ  09/10/13  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Levanta Oportunidades de Negocio                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_LEVOPORT(nTip)
Local cQuery  := ""
Local cQAlias := "SQLALIAS"
Local cFasFim := ""
Local nQtdFas := 0
Local lVAI_VABAON := ( VAI->(FieldPos("VAI_VABAON")) > 0 )
Local lVDM_OPCFAB := ( VDM->(FieldPos("VDM_OPCFAB")) > 0 )
//
aVerOport := {}
//
cQuery := "SELECT DISTINCT VDK.VDK_CODFAS FROM "+RetSqlName("VDK")+" VDK WHERE VDK.VDK_FILIAL='"+xFilial("VDK")+"' AND VDK.VDK_FIMFAS='1' AND VDK.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
Do While !( cQAlias )->( Eof() )
	cFasFim += "'"+( cQAlias )->( VDK_CODFAS )+"',"
	nQtdFas++
	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )
If !Empty(cFasFim)
	cFasFim := left(cFasFim,len(cFasFim)-1)
	cQuery := "SELECT VDL.VDL_CODCLI , VDL.VDL_LOJCLI , VDL.VDL_NOMCLI , VDM.R_E_C_N_O_ AS RECVDM , VDM.VDM_CAMPOP , "
	cQuery += "VDM.VDM_CODMAR , VDM.VDM_MODVEI , VDM.VDM_CORVEI , VDM.VDM_QTDINT , VDM.VDM_DATINT , VDM.VDM_DATLIM "
	If lVDM_OPCFAB
		cQuery += ", VDM.VDM_OPCFAB "
	EndIf
	cQuery += "FROM "+RetSqlName("VDM")+" VDM "
	cQuery += "JOIN "+RetSqlName("VDL")+" VDL ON ( VDL.VDL_FILIAL=VDM.VDM_FILIAL AND VDL.VDL_CODOPO=VDM.VDM_CODOPO AND VDL.VDL_CODCLI<>' ' AND VDL.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VDM.VDM_FILIAL='"+xFilial("VDM")+"' AND "
	If !Empty(cVV9CCli+cVV9LCli)
		cQuery += "VDL.VDL_CODCLI='"+cVV9CCli+"' AND "
		If !lAllLoja
			cQuery += "VDL.VDL_LOJCLI='"+cVV9LCli+"' AND "
		EndIf
	EndIf
	If nQtdFas == 1
		cQuery += "VDM.VDM_CODFAS="+cFasFim+" AND "
	Else
		cQuery += "VDM.VDM_CODFAS IN ("+cFasFim+") AND "
	EndIf
	If !Empty(dVDMDInt)
		cQuery += "VDM.VDM_DATINT<='"+dtos(dVDMDInt)+"' AND VDM.VDM_DATLIM>='"+dtos(dVDMDInt)+"' AND "
	EndIf
	cQuery += "VDM.VDM_MOTCAN=' ' AND VDM.VDM_FILATE=' ' AND VDM.VDM_NUMATE=' ' AND "
	If !Empty(M->VDM_CAMPOP)
		cQuery += "VDM.VDM_CAMPOP='"+M->VDM_CAMPOP+"' AND "
	EndIf
	If !Empty(cFilCodMar)
		cQuery += "VDM.VDM_CODMAR='"+cFilCodMar+"' AND "
	EndIf
	If !Empty(cVDMCMod)
		cQuery += "VDM.VDM_MODVEI='"+cVDMCMod+"' AND "
	EndIf
	If !Empty(cVDMCCor)
		cQuery += "VDM.VDM_CORVEI='"+cVDMCCor+"' AND "
	EndIf
	If lVAI_VABAON
		If VAI->VAI_VABAON == "1" // 1=Somente do Vendedor
			cQuery += "VDM.VDM_CODVEN='"+VAI->VAI_CODVEN+"' AND "
		EndIf
	Else
		cQuery += "( VDM.VDM_CODVEN=' ' OR VDM.VDM_CODVEN='"+VAI->VAI_CODVEN+"' ) AND "
	EndIf
	cQuery += "VDM.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
	Do While !( cQAlias )->( Eof() )
		aAdd(aVerOport,{ .f. , ( cQAlias )->( VDM_CAMPOP ) , ( cQAlias )->( VDM_CODMAR ) , ( cQAlias )->( VDM_MODVEI ) , ( cQAlias )->( VDM_CORVEI ) ,;
								( cQAlias )->( VDM_QTDINT ) , stod(( cQAlias )->( VDM_DATINT )) , stod(( cQAlias )->( VDM_DATLIM )) , ;
								( cQAlias )->( VDL_CODCLI ) , ( cQAlias )->( VDL_LOJCLI ) , ( cQAlias )->( VDL_NOMCLI ) , ;
								( cQAlias )->( RECVDM ) , IIf(lVDM_OPCFAB,( cQAlias )->( VDM_OPCFAB ),"") })
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
EndIf
If len(aVerOport) <= 0
	aAdd(aVerOport,{ .f. , "" , "" , "" , "" ,	0 , ctod("") , ctod("") , "" , "" , "" , 0 , "" })
EndIf
If nTip > 0
	oLbVerOpo:nAt := 1
	oLbVerOpo:SetArray(aVerOport)
	oLbVerOpo:bLine := { || {	IIf(aVerOport[oLbVerOpo:nAt,01],oOkTik,oNoTik) ,;
								aVerOport[oLbVerOpo:nAt,02] ,;
								aVerOport[oLbVerOpo:nAt,03],aVerOport[oLbVerOpo:nAt,04],aVerOport[oLbVerOpo:nAt,05] ,;
								aVerOport[oLbVerOpo:nAt,13] ,;
								FG_AlinVlrs(Transform(aVerOport[oLbVerOpo:nAt,06],"@E 999,999")) ,;
								Transform(aVerOport[oLbVerOpo:nAt,07],"@D") ,;
								Transform(aVerOport[oLbVerOpo:nAt,08],"@D") ,;
								aVerOport[oLbVerOpo:nAt,09]+"-"+aVerOport[oLbVerOpo:nAt,10]+" "+aVerOport[oLbVerOpo:nAt,11] }}
	oLbVerOpo:SetFocus()
	oLbVerOpo:Refresh()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_LEVANTA บ Autor ณ Andre Luis Almeida บ Data ณ  29/03/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Levanta Clientes                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_LEVANTA(nTip)
Local cQuery    := ""
Local cQALSA1   := "SQLSA1"
Local aClientes := {}
Local nPos      := 0
If nTip == 1 
	If !Empty(cVV9CCli) .and. Empty(cVV9LCli)
		cVV9LCli := FM_SQL("SELECT SA1.A1_LOJA FROM "+RetSQLName("SA1")+" SA1 WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD='"+cVV9CCli+"' AND SA1.D_E_L_E_T_=' '")
	EndIf
EndIf
If ( nTip == 1 .and. !Empty(cVV9CCli) .and. !Empty(cVV9LCli) ) .or. ;
	( nTip == 2 .and. !Empty(cVV9NCli) ) .or. ;
	( nTip == 3 .and. !Empty(cVV9FCli) ) .or. ;
	( nTip == 4 .and. !Empty(cVV9ECli) )
	cQuery := "SELECT SA1.A1_COD , SA1.A1_LOJA , SA1.A1_NOME , SA1.A1_TEL , SA1.A1_EMAIL FROM "+RetSqlName("SA1")+" SA1 WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND "
	Do Case
		Case nTip == 1 // Codigo
			If !Empty(cVV9CCli) .and. !Empty(cVV9LCli)
				cQuery += "SA1.A1_COD='"+cVV9CCli+"' AND SA1.A1_LOJA='"+cVV9LCli+"' AND "
			Else
				cQuery += "SA1.A1_COD='__________' AND " // NAO LEVANTAR
			EndIf
		Case nTip == 2 // Nome
			cQuery += "SA1.A1_NOME LIKE '"+Alltrim(cVV9NCli)+"%' AND "
		Case nTip == 3 // Fone
			cQuery += "SA1.A1_TEL LIKE '%"+Alltrim(cVV9FCli)+"%' AND "
		Case nTip == 4 // E-mail
			cQuery += "( SA1.A1_EMAIL LIKE '%"+Alltrim(cVV9ECli)+"%' OR SA1.A1_EMAIL LIKE '%"+LOWER(Alltrim(cVV9ECli))+"%' ) AND "
	EndCase
	cQuery += "SA1.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQALSA1, .F., .T. )
	Do While !( cQALSA1 )->( Eof() )
		aAdd(aClientes,{ ( cQALSA1 )->( A1_COD ) , ( cQALSA1 )->( A1_LOJA ) , ( cQALSA1 )->( A1_NOME ) , ( cQALSA1 )->( A1_TEL ) , ( cQALSA1 )->( A1_EMAIL ) })
		( cQALSA1 )->( DbSkip() )
	EndDo
	( cQALSA1 )->( dbCloseArea() )
	cVV9CCli := space(TamSx3("VV9_CODCLI")[1])
	cVV9LCli := space(TamSx3("VV9_LOJA")[1])
	cVV9NCli := space(TamSx3("VV9_NOMVIS")[1])
	cVV9FCli := space(TamSx3("VV9_TELVIS")[1])
	cVV9ECli := space(TamSx3("A1_EMAIL")[1])
	If len(aClientes) == 1
		nPos := 1
	ElseIf len(aClientes) > 1 // Selecionar Cliente
		DEFINE MSDIALOG oClientes FROM 000,000 TO 022,100 TITLE STR0020 OF oMainWnd // Selecionar Cliente
		@ 002,002 TO 163,394 LABEL (" "+STR0020+" ") OF oClientes PIXEL // Selecionar Cliente
		@ 010,002 LISTBOX oLbClientes FIELDS HEADER STR0021,; // Codigo/Loja
			STR0004,; // Nome
			STR0005,; // Telefone
			STR0006;  // E-mail
			COLSIZES 40,120,60,100 SIZE 392,151 OF oClientes PIXEL ON DBLCLICK (nPos:=oLbClientes:nAt,oClientes:End())
			oLbClientes:SetArray(aClientes)
			oLbClientes:bLine := { || { aClientes[oLbClientes:nAt,01]+"-"+aClientes[oLbClientes:nAt,02],;
					aClientes[oLbClientes:nAt,03],;
					aClientes[oLbClientes:nAt,04],;
					aClientes[oLbClientes:nAt,05] }}
		ACTIVATE MSDIALOG oClientes CENTER 
	EndIf
	If nPos > 0 // Atualiza Variaveis da TELA
		cVV9CCli := aClientes[nPos,1]
		cVV9LCli := aClientes[nPos,2]
		cVV9NCli := aClientes[nPos,3]
		cVV9FCli := aClientes[nPos,4]
		cVV9ECli := aClientes[nPos,5]
	EndIf
	FS_LEVATEND(1) // Levanta os Atendimentos do Cliente selecionado
	FS_TXTBOTAO(aVerAtend[1,05])
EndIf
If Empty(Alltrim(cVV9CCli+cVV9LCli+cVV9NCli+cVV9FCli+cVV9ECli))
	FS_LIMPAR()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณFS_VXC002DBLบ Autor ณ Andre Luis Almeida บ Data ณ 10/10/13  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Duplo Clique no ListBox de Oportunidade de Negocios        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VXC002DBL(nLinha)
Local aAux := {}
Local ni   := 0
Local nPos := 0
If aVerOport[nLinha,12] > 0
	aVerOport[nLinha,1] := !aVerOport[nLinha,1]
	If Empty(cVV9CCli+cVV9LCli) .and. aVerOport[nLinha,1]
		For ni := 1 to len(aVerOport)
			If aVerOport[ni,1]
				aAdd(aAux,aVerOport[ni,12])
			EndIf
		Next
		cVV9CCli := aVerOport[nLinha,09]
		cVV9LCli := aVerOport[nLinha,10]
		FS_LEVANTA(1) // Carregar Registros
		For ni := 1 to len(aAux)
			nPos := aScan(aVerOport, {|x| x[12] == aAux[ni] } )
			If nPos > 0
				aVerOport[nPos,1] := .t.
			EndIf
		Next
		oLbVerOpo:Refresh()
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_LIMPAR บ Autor ณ Andre Luis Almeida บ Data ณ  10/10/13  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Duplo Clique no ListBox de Oportunidade de Negocios        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                      
Static Function FS_LIMPAR()
cVV9CCli := space(TamSx3("VV9_CODCLI")[1])
cVV9LCli := space(TamSx3("VV9_LOJA")[1])
cVV9NCli := space(TamSx3("VV9_NOMVIS")[1])
cVV9FCli := space(TamSx3("VV9_TELVIS")[1])
cVV9ECli := space(TamSx3("A1_EMAIL")[1])
FS_LEVATEND(1) // Levanta os Atendimentos do Cliente selecionado
FS_TXTBOTAO(aVerAtend[1,05])
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao   ณ FS_ORDVETณ Autor ณ Andre Luis Almeida     ณ Data ณ 10/10/13 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricaoณ Ordenar VETOR                                               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ORDVET(nCol)
If strzero(nCol,1) == left(cOrdVet,1)
	If right(cOrdVet,1) == "C"
		cOrdVet := strzero(nCol,1)+"D" // Decrescente
	Else
		cOrdVet := strzero(nCol,1)+"C" // Crescente
	EndIf
Else
	cOrdVet := strzero(nCol,1)+"C" // Crescente
EndIf
If right(cOrdVet,1) == "C"
	aSort(aVerOport,,,{|x,y| x[nCol] < y[nCol] })
Else
	aSort(aVerOport,,,{|x,y| x[nCol] > y[nCol] })
EndIf
oLbVerOpo:Refresh()
oLbVerOpo:SetFocus()
Return()