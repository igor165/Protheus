// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 07     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "VEIXC005.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEIXC005 º Autor ³ Rafael Goncalves   º Data ³  01/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Tela Consulta  - Opcionais e acessorios do VEICULO/MODELO  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aParOpc (Vetor de Posicionamento)                          º±±
±±º          ³ 		aParOpc[1] = Chassi Interno (CHAINT) *                º±±
±±º          ³ 		aParOpc[2] = Marca                                    º±±
±±º          ³ 		aParOpc[3] = Modelo                                   º±±
±±º          ³ cOpcDefault (Opcionais Default)                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos -> Novo Atendimento                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXC005(aParOpc,cOpcDefault) 
Local aObjects      := {} , aPosObj := {} , aInfo := {} //aPosObjApon := {} , "
Local aSizeAut      := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)		
Local nCntFor       := 0 
Local cCor          := ""
Local nTam          := 0
Local cOpcFab       := ""
Local aAcesso       := {}
Local oBran         := LoadBitmap( GetResources() , "BR_BRANCO" ) // Opcional do Modelo
Local oAzul         := LoadBitmap( GetResources() , "BR_AZUL" )   // Opcional do Veiculo
Local nVlrOpc       := 0
Local nOpcao        := 0 
Local cSomaVlr      := ""
Local cTitTela      := ""
Local lVVW_SOMAVL   := ( VVW->(FieldPos("VVW_SOMAVL")) > 0 )
Default cOpcDefault := ""
aParOpc[2] := left(aParOpc[2]+space(10),TamSx3("VV1_CODMAR")[1])
aParOpc[3] := lefT(aParOpc[3]+space(50),TamSx3("VV1_MODVEI")[1])
If !Empty(aParOpc[1])
	DbSelectArea("VV1")
	DbSetOrder(1)
	DbSeek(xFilial("VV1")+aParOpc[1])
	aParOpc[2] := VV1->VV1_CODMAR
	aParOpc[3] := VV1->VV1_MODVEI
	cOpcFab  := VV1->VV1_OPCFAB
	cTitTela += Alltrim(VV1->VV1_CHASSI)+" - "
EndIf
If !Empty(cOpcDefault)
	cOpcFab := cOpcDefault // Carregar os Opcionais passados como Default
EndIf
nTam := at("/",cOpcFab)
If nTam > 1
	nTam--
EndIf
VV2->(dbSetOrder(1))
VV2->(dbSeek(xFilial("VV2")+aParOpc[2]+aParOpc[3]))
cTitTela += Alltrim(aParOpc[2])+" "+Alltrim(VV2->VV2_DESMOD)
If nTam <= 0
	nTam := VVW->(TamSx3("VVW_CODOPC")[1])
EndIf
//levanta as informacoes 
DbSelectArea("VVM")
DbSetOrder(1)
If dbSeek(xFilial("VVM")+aParOpc[2]+aParOpc[3])
	While !EOF() .and. xFilial("VVM")+aParOpc[2]+aParOpc[3] == VVM->VVM_FILIAL+VVM->VVM_CODMAR+VVM->VVM_MODVEI
		dbSelectArea("VVW")
		dbSetOrder(1)
		If dbSeek(xFilial("VVW")+VVM->VVM_CODMAR+VVM->VVM_CODOPC)
			nVlrOpc := VVM->VVM_VALCON
			If nVlrOpc <= 0
				nVlrOpc := VVM->VVM_VALOPC
			EndIf
			If nVlrOpc <= 0
				nVlrOpc := VVW->VVW_VALOPC
			EndIf
			cCor := "B" // Branco
			cSomaVlr := "Nao"
	    	If !Empty(cOpcFab)
	        	If left(VVW->VVW_CODOPC,nTam) $ cOpcFab
					cCor := "A" // Azul
					If lVVW_SOMAVL
						cSomaVlr := X3CBOXDESC("VVW_SOMAVL",left(Alltrim(VVW->VVW_SOMAVL)+"0",1))
					EndIf
				EndIf
			EndIf
			aAdd(aAcesso, { cCor , alltrim(VVW->VVW_CODOPC) , VVW->VVW_DESOPC , nVlrOpc , cSomaVlr } ) 
		EndIf
		dbSelectArea("VVM")
		dbSkip()
	EndDo
EndIf
If Len(aAcesso) <= 0
	aAdd(aAcesso, {	"B" , "" , "" , 0 , "" } )
EndIf
aSort(aAcesso,,,{|x,y| x[2] < y[2] })
// Configura os tamanhos dos objetos													  		
aObjects := {}
AAdd( aObjects, { 1, 10, .T. , .T. } ) // Listbox 
AAdd( aObjects, { 1, 15, .T. , .F. } ) // Legenda
// Fator de reducao de 0.8
for nCntFor := 1 to Len(aSizeAut)
	aSizeAut[nCntFor] := INT(aSizeAut[nCntFor] * 0.8)
next   
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)    
DEFINE MSDIALOG oOpcionais TITLE (STR0001+" - "+cTitTela) From aSizeAut[7],000 TO aSizeAut[6]-5,aSizeAut[5] of oMainWnd STYLE DS_MODALFRAME STATUS PIXEL // Opcionais do Modelo/Veiculo

	@ aPosObj[1,1]+002,aPosObj[1,2]+002 LISTBOX oLbAce FIELDS HEADER "",STR0002,STR0003,STR0004,STR0005 COLSIZES 10,40,200,50,70 SIZE aPosObj[1,4]-2,aPosObj[1,3]-aPosObj[1,1] OF oOpcionais PIXEL // Opcional / Descricao / Valor / Soma Vlr Veiculo

	oLbAce:SetArray(aAcesso)
	oLbAce:bLine := { || { IIf(aAcesso[oLbAce:nAt,01]=="A",oAzul,oBran) ,;
								aAcesso[oLbAce:nAt,02] ,;
								aAcesso[oLbAce:nAt,03] ,;
								FG_AlinVlrs(Transform(aAcesso[oLbAce:nAt,04],"@E 99,999,999.99")) ,;
								aAcesso[oLbAce:nAt,05] }}

	@ aPosObj[2,1]+002,050 BITMAP oxBran RESOURCE "BR_BRANCO" OF oOpcionais NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosObj[2,1]+002,060 SAY STR0006 SIZE 150,8 OF oOpcionais PIXEL COLOR CLR_BLUE // Opcionais do Modelo
	@ aPosObj[2,1]+002,250 BITMAP oxAzul RESOURCE "BR_AZUL" OF oOpcionais NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosObj[2,1]+002,260 SAY STR0007 SIZE 150,8 OF oOpcionais PIXEL COLOR CLR_BLUE // Opcionais do Veiculo

ACTIVATE MSDIALOG oOpcionais CENTER ON INIT  EnchoiceBar(oOpcionais,{ || nOpcao := 1, oOpcionais:End()},{|| oOpcionais:End() } ) 
Return()