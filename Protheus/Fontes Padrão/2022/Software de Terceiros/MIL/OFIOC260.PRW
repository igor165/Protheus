#Include "protheus.ch"
#Include "OFIOC260.CH" 

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  30/10/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007345_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ OFIOC260 ³ Autor ³ Andre Luis Almeida     ³ Data ³ 02/04/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Veiculos - Consulta Envio/Retorno VI7/VJ2                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOC260()
Local OXvermelho 
Local OXverde
Local OXazull
Local OXcinza
Private overde   := LoadBitmap( GetResources(), "BR_verde")
Private overmelho:= LoadBitmap( GetResources(), "BR_vermelho")
Private oazull   := LoadBitmap( GetResources(), "BR_azul")
Private ocinza   := LoadBitmap( GetResources(), "BR_cinza")
Private cMar := left(FG_MARCA("CHEVROLET",,.f.)+space(3),3)
Private dDtI := dDataBase - day(dDataBase) + 1
Private dDtF := dDataBase
Private aEnv := {}
Private aRet := {}
Private aStatus := {STR0001,STR0002,STR0003,STR0004,STR0005}	 //Todos # Aceitos # Rejeitados # Enviados # Em manutencao
Private cStatus := STR0001			//Todos

FS_FILTRAR("0")
DEFINE MSDIALOG oEnvRet TITLE STR0006 From 5,08 to 29,92 of oMainWnd  //Veiculos - Envio/Retorno

	@ 007,004 SAY STR0007 SIZE 45,40 OF oEnvRet PIXEL COLOR CLR_BLUE //Marca:
	@ 006,022 MSGET oMar VAR cMar F3 "VE1" PICTURE "@!" SIZE 20,8 OF oEnvRet PIXEL COLOR CLR_BLUE

	@ 007,054 SAY STR0008 SIZE 45,40 OF oEnvRet PIXEL COLOR CLR_BLUE    //Data:
	@ 006,067 MSGET oDtI VAR dDtI PICTURE "@D" SIZE 30,8 OF oEnvRet PIXEL COLOR CLR_BLUE
	@ 007,102 SAY STR0009 SIZE 15,40 OF oEnvRet PIXEL COLOR CLR_BLUE  //ate
	@ 006,111 MSGET oDtF VAR dDtF VALID ( dDtF >= dDtI )PICTURE "@D" SIZE 30,8 OF oEnvRet PIXEL COLOR CLR_BLUE

	@ 007,147 SAY STR0010 SIZE 45,40 OF oEnvRet PIXEL COLOR CLR_BLUE  //Status:
	@ 006,164 MSCOMBOBOX oStatus VAR cStatus ITEMS aStatus SIZE 50,08 OF oEnvRet PIXEL COLOR CLR_BLUE
                                             
	@ 006,218 BUTTON oFiltrar PROMPT STR0011 OF oEnvRet SIZE 61,10 PIXEL ACTION (FS_FILTRAR("1"),FS_RET(),oLbEnv:SetFocus())   //<<< F I L T R A R >>>
	@ 006,283 BUTTON oSair PROMPT STR0012 OF oEnvRet SIZE 45,10 PIXEL ACTION (oEnvRet:End()) //<<< S A I R >>>

	@ 022,001 LISTBOX oLbEnv FIELDS HEADER OemToAnsi(""),;				// Cor
														OemToAnsi(STR0013),;		// Dt.Venda
														OemToAnsi(STR0014),;		 		// NF
														OemToAnsi(STR0015),;		// Veiculo
                                       	OemToAnsi(STR0016);		// Cliente
	COLSIZES 10,25,25,70,70 SIZE 331,082 OF oEnvRet PIXEL ON CHANGE (FS_RET(),oLbEnv:SetFocus()) ON DBLCLICK ( OFIIA070(ctod(aEnv[oLbEnv:nAt,1]),substr(aEnv[oLbEnv:nAt,3],4),{2},.f.) )
	oLbEnv:SetArray(aEnv)
	oLbEnv:bLine := { || {If(aEnv[oLbEnv:nAt,5]=="verd",overde,If(aEnv[oLbEnv:nAt,5]=="verm",overmelho,If(aEnv[oLbEnv:nAt,5]=="azul",oazull,ocinza))),;
								aEnv[oLbEnv:nAt,1] ,;
                        aEnv[oLbEnv:nAt,2] ,;
                        aEnv[oLbEnv:nAt,3] ,;
                        aEnv[oLbEnv:nAt,4] }}


	@ 105,001 LISTBOX oLbRet FIELDS HEADER OemToAnsi(""),;				// Cor
														OemToAnsi(STR0017),;		// Retorno
                                       	OemToAnsi(STR0018);		// Mensagem
	COLSIZES 10,45,50 SIZE 331,063 OF oEnvRet PIXEL 
	oLbRet:SetArray(aRet)
	oLbRet:bLine := { || {If(aRet[oLbRet:nAt,4]=="verd",overde,If(aRet[oLbRet:nAt,4]=="verm",overmelho,If(aRet[oLbRet:nAt,4]=="azul",oazull,ocinza))),;
								aRet[oLbRet:nAt,1] +" "+ aRet[oLbRet:nAt,2] ,;
                        aRet[oLbRet:nAt,3] }}

	@ 171,018 BITMAP OXverde RESOURCE "BR_verde" OF oEnvRet PIXEL NOBORDER SIZE 10,10 when .f.
	@ 172,030 SAY STR0002 SIZE 80,10 OF oEnvRet PIXEL COLOR CLR_BLUE   //Aceitos
	@ 171,088 BITMAP OXvermelho RESOURCE "BR_vermelho" OF oEnvRet PIXEL NOBORDER SIZE 10,10 when .f.
	@ 172,100 SAY STR0003 SIZE 80,10 OF oEnvRet PIXEL COLOR CLR_BLUE //Rejeitados
	@ 171,158 BITMAP OXazull RESOURCE "BR_azul" OF oEnvRet PIXEL NOBORDER SIZE 10,10 when .f.
	@ 172,170 SAY STR0004 SIZE 80,10 OF oEnvRet PIXEL COLOR CLR_BLUE   //Enviados
	@ 171,228 BITMAP OXcinza RESOURCE "BR_cinza" OF oEnvRet PIXEL NOBORDER SIZE 10,10 when .f.
	@ 172,240 SAY STR0005 SIZE 80,10 OF oEnvRet PIXEL COLOR CLR_BLUE  //Em manutencao

ACTIVATE MSDIALOG oEnvRet CENTER 
Return(.t.)

Static Function FS_FILTRAR(cTip)
Local cCond := ".t."
Local cCor  := ""
Local lOk := .t.
aEnv := {}
DbSelectArea("VI7")
DbSetOrder(1)
If !Empty(cMar)
	DbSeek(xFilial("VI7")+cMar+dtos(dDtI),.t.)
	cCond := "cMar == VI7->VI7_CODMAR .and. dDtF >= VI7->VI7_DTAVDA"
Else
	DbSeek(xFilial("VI7"))
EndIf
Do While !Eof() .and. VI7->VI7_FILIAL == xFilial("VI7") .and. &cCond
	If cCond == ".t."
		If dDtI > VI7->VI7_DTAVDA .or. dDtF < VI7->VI7_DTAVDA
			DbSelectArea("VI7")
		   DbSkip()
		   Loop
		EndIf
	EndIf
	cCor := ""
	If !Empty(VI7->VI7_STATUS)
		cCor := "azul"
		DbSelectArea("VJ2")
		DbSetOrder(1)
		DbSeek(xFilial("VJ2")+VI7->VI7_CODMAR+VI7->VI7_CHASSI+"ZZZ",.t.)
		If VI7->VI7_NUMNFI+VI7->VI7_CODMAR+VI7->VI7_CHASSI # VJ2->VJ2_NUMNFI+VJ2->VJ2_CODMAR+VJ2->VJ2_CHASSI
			DbSelectArea("VJ2")
			DbSkip(-1)
		EndIf
		If VI7->VI7_NUMNFI+VI7->VI7_CODMAR+VI7->VI7_CHASSI == VJ2->VJ2_NUMNFI+VJ2->VJ2_CODMAR+VJ2->VJ2_CHASSI
			If Empty(VJ2->VJ2_ERRO)
				cCor := "verd"
			ElseIf VJ2->VJ2_ERRO == "ER"
				cCor := "verm"
			EndIf
		EndIf
	EndIf
	lOk := .t.
	If cStatus # STR0001           				//Todos
		If cStatus == STR0002     				//Aceitos
			If cCor # "verd"
				lOk := .f.
			EndIf
		ElseIf cStatus == STR0003         //Rejeitados
			If cCor # "verm"                    //
				lOk := .f.
			EndIf
		ElseIf cStatus == STR0004           //Enviados
			If cCor # "azul"                    //
				lOk := .f.
			EndIf
		ElseIf cStatus == STR0005      //Em manutencao
			If !Empty(cCor)
				lOk := .f.
			EndIf		
		EndIf
	EndIf
	If lOk
		Aadd(aEnv,{Transform(VI7->VI7_DTAVDA,"@D"),VI7->VI7_NUMNFI,VI7->VI7_CODMAR+VI7->VI7_CHASSI,VI7->VI7_NOMCLI,cCor})
	EndIf
	DbSelectArea("VI7")
   DbSkip()
EndDo
If len(aEnv) <= 0
	Aadd(aEnv,{"","","","",""})
EndIf
aSort(aEnv,,,{|x,y| dtos(ctod(x[1])) > dtos(ctod(y[1])) })
If cTip == "1" // Filtro
	oLbEnv:nAt := 1
	oLbEnv:SetArray(aEnv)
	oLbEnv:bLine := { || {If(aEnv[oLbEnv:nAt,5]=="verd",overde,If(aEnv[oLbEnv:nAt,5]=="verm",overmelho,If(aEnv[oLbEnv:nAt,5]=="azul",oazull,ocinza))),;
								aEnv[oLbEnv:nAt,1] ,;
                        aEnv[oLbEnv:nAt,2] ,;
                        aEnv[oLbEnv:nAt,3] ,;
                        aEnv[oLbEnv:nAt,4] }}
	oLbEnv:SetFocus()
EndIf
Return 

Static Function FS_RET()
Local cCor := ""
aRet := {}
If aEnv[oLbEnv:nAt,5] == "azul"   
	cCor := "azul"
EndIf
DbSelectArea("VJ2")
DbSetOrder(1)
DbSeek(xFilial("VJ2")+Alltrim(aEnv[oLbEnv:nAt,3]))
Do While !Eof() .and. VJ2->VJ2_FILIAL == xFilial("VJ2") .and. ( Alltrim(VJ2->VJ2_CODMAR+VJ2->VJ2_CHASSI) == Alltrim(aEnv[oLbEnv:nAt,3]) )
	If aEnv[oLbEnv:nAt,2] == VJ2->VJ2_NUMNFI
		cCor := ""
		If aEnv[oLbEnv:nAt,5] == "azul"     
			cCor := "azul"   
		ElseIf Empty(VJ2->VJ2_ERRO)
			cCor := "verd"
		ElseIf VJ2->VJ2_ERRO == "ER"
			cCor := "verm"
		EndIf
		Aadd(aRet,{Transform(VJ2->VJ2_DATENV,"@D"),Transform(VJ2->VJ2_HORENV,"@R 99:99"),VJ2->VJ2_ERRO+" "+VJ2->VJ2_MENSAG,cCor})
	EndIf
	DbSelectArea("VJ2")
   DbSkip()
EndDo
If len(aRet) <= 0
	Aadd(aRet,{"","","",cCor})
EndIf
aSort(aRet,,,{|x,y| dtos(ctod(x[1]))+x[2] > dtos(ctod(y[1]))+y[2] })
oLbRet:nAt := 1
oLbRet:SetArray(aRet)
oLbRet:bLine := { || {If(aRet[oLbRet:nAt,4]=="verd",overde,If(aRet[oLbRet:nAt,4]=="verm",overmelho,If(aRet[oLbRet:nAt,4]=="azul",oazull,ocinza))),;
								aRet[oLbRet:nAt,1] +" "+ aRet[oLbRet:nAt,2] ,;
                        aRet[oLbRet:nAt,3] }}
oLbRet:SetFocus()
oLbRet:Refresh()
Return