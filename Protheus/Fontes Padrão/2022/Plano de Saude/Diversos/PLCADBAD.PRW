#include "protheus.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAXCADBAD  บAutor  ณRoger Cangianeli    บ Data ณ  13/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Log dos registros corretos da contabilizacao do PLS.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAlteracoesณ 13/07/06 -Incl.filtros para expressoes na exportacao.RC    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PLCADBAD()

LOCAL _aArea	:= GetArea()
//Local aRotina	:= {}
Local cCadastro	:= ''

dbSelectARea("BAD")
dbSetOrder(1)

aRotina   := {	{"Pesquisar" ,"AxPesqui",0,1} ,;
{"Visualizar","AxVisual",0,2} ,;     
{"Exportar"  ,"PLEXPBAD",0,5} }

cCadastro := OemToAnsi("Log Contabiliza็ใo Correta do PLS")

mBrowse(06,01,22,75,'BAD',,)

RestArea(_aArea)

Return




Function PLEXPBAD()
Local cFile
If Aviso('Exporta็ใo de Log','Confirma exporta็ใo de log para arquivo?',{"Prosseguir","Cancelar"},1,"Escolha") == 2
	Return
EndIf

cFile := cGetFile("Arquivos Texto|*.TXT",OemToAnsi("Salvar Arquivo Como..."))

If !Empty(cFile)
	MsAguarde({|| fRunExp(cFile) }, "Exportando arquivo...", "", .T.)
EndIf

Return



Static Function fRunExp(cFile)
Local aDatas	:= {}
LOCAL _lErroArq	:= .F.

aDatas	:= fPergData()
If aDatas[1] == Ctod('01/01/1980') .and. aDatas[2]== Ctod('01/01/1980') .and. aDatas[5] == 'RETURN'
	Aviso('Aviso','Rotina cancelada pelo usuแrio.',{"Ok"},2,"")
	Return
EndIf

If !File(cFile)
	nHand	:= fCreate(cFile, 1)
Else
	nHand	:= fOpen(cFile, 2)
EndIf

// Posiciona no final do arquivo para fazer a gravacao
fSeek(nHand, 0, 2)



// Executa query para filtrar dados a exportar
cQuery	:= "SELECT BAD_DATA, BAD_HORA, BAD_LOG, BAD_LOG1 FROM "+RetSqlName("BAD")+" "
cQuery	+= "WHERE BAD_FILIAL = '"+xFilial('BAD')+"' AND D_E_L_E_T_ = '' "
cQuery	+= "AND BAD_DATA >= '"+DtoS(aDatas[1])+"' AND BAD_DATA <= '"+DtoS(aDatas[2])+"' "
cQuery	+= "AND BAD_HORA >= '"+Subs(aDatas[3],1,2)+":"+Subs(aDatas[3],3,2)+":"+Subs(aDatas[3],5,2)+"' "
cQuery	+= "AND BAD_HORA <= '"+Subs(aDatas[4],1,2)+":"+Subs(aDatas[4],3,2)+":"+Subs(aDatas[4],5,2)+"' "
If !Empty(aDatas[5])
	cQuery	+= "AND BAD_LOG||BAD_LOG1 LIKE '%"+  AllTrim(aDatas[5]) +"%' "
EndIf
cQuery	+= "ORDER BY BAD_FILIAL, BAD_DATA, BAD_HORA "
cQuery	:= ChangeQuery(cQuery)
PlsQuery(cQuery,'TRB')


dbSelectArea('TRB')
ProcRegua(RecCount())
dbGoTop()
If Eof()
	_lErroArq	:= .T.	
Else
While !Eof()
	IncProc()
	// Efetua gravacao do arquivo
	fWrite(nHand, CHR(10)+Dtoc(TRB->BAD_DATA)+'|'+TRB->BAD_HORA+'|'+TRB->BAD_LOG+TRB->BAD_LOG1)
	dbSkip()
End
EndIf

dbCloseArea()

// Fecha arquivo
If !fClose(nHand)
	Aviso('Aten็ใo','Erro ao fechar o arquivo.',{"Ok"},2,"")
Else
	If !_lErroArq	
	Aviso('Fim de processamento','Arquivo gerado com sucesso.'+CHR(13)+cFile,{"Ok"},2,"")
	Else
	Aviso('Aten็ใo','Nใo foram encontrados dados para gera็ใo do arquivo.'+CHR(13)+cFile,{"Ok"},2,"")
	EndIf
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfPergData บAutor  ณRoger/Clarice       บ Data ณ  09/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function fPergData()
Local _dDataDe  := Date()
Local _dDataAte := Date()
Local _cHoraDe  := "000000"
Local _cHoraAte := "235959"
Local _cExp		:= Space(20)
Local bCanc    	:= {|| _oDlg:End(), _dDataDe:=CtoD('01/01/1980'), _dDataAte:=CtoD('01/01/1980'), _cHoraDe:="000000", _cHoraAte:="235959",_cExp:='RETURN'}

DEFINE MSDIALOG _oDlg TITLE OemtoAnsi("Exporta็ใo de Log") FROM C(100),C(100) TO C(300),C(300) PIXEL


// Cria Componentes Padroes do Sistema
@ C(006),C(012) Say "Digite o perํodo que deseja exportar" Size C(133),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
@ C(015),C(012) Say "Data de:" Size C(022),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
@ C(015),C(040) MsGet oEdit1 Var _dDataDe 	Size C(032),C(009) COLOR CLR_BLACK PIXEL OF _oDlg Picture "@D" Valid .T.
@ C(028),C(012) Say "Data At้:" Size C(022),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
@ C(028),C(040) MsGet oEdit2 Var _dDataAte	Size C(032),C(009) COLOR CLR_BLACK PIXEL OF _oDlg Picture "@D" Valid .T.
@ C(041),C(012) Say "Hora de:" Size C(022),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
@ C(041),C(040) MsGet oEdit1 Var _cHoraDe 	Size C(032),C(009) COLOR CLR_BLACK PIXEL OF _oDlg Picture "@R 99:99:99" Valid .T.
@ C(054),C(012) Say "Hora At้:" Size C(022),C(008) COLOR CLR_BLACK PIXEL OF _oDlg                             
@ C(054),C(040) MsGet oEdit2 Var _cHoraAte	Size C(032),C(009) COLOR CLR_BLACK PIXEL OF _oDlg Picture "@R 99:99:99" Valid .T.
@ C(067),C(012) Say "Expressao:" Size C(022),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
@ C(067),C(040) MsGet oEdit2 Var _cExp	Size C(042),C(009) COLOR CLR_BLACK PIXEL OF _oDlg Valid .T.

DEFINE SBUTTON FROM C(084),C(053) TYPE 1 ENABLE OF _oDlg ACTION (_oDlg:End())
DEFINE SBUTTON FROM C(084),C(075) TYPE 2 ENABLE OF _oDlg ACTION ( Eval(bCanc) )

ACTIVATE MSDIALOG _oDlg CENTERED

Return({_dDataDe,_dDataAte,_cHoraDe,_cHoraAte,AllTrim(_cExp)})


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma   ณ   C()      ณ Autor ณ Norbert Waage Junior  ณ Data ณ10/05/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao  ณ Funcao responsavel por manter o Layout independente da       ณฑฑ
ฑฑณ           ณ resolu็ใo horizontal do Monitor do Usuario.                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function C(nTam)
Local nHRes	:=	oMainWnd:nClientWidth	//Resolucao horizontal do monitor
Do Case
	Case nHRes == 640	//Resolucao 640x480
		nTam *= 0.8
	Case nHRes == 800	//Resolucao 800x600
		nTam *= 1
	OtherWise			//Resolucao 1024x768 e acima
		nTam *= 1.28
EndCase
If "MP8" $ oApp:cVersion
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTratamento para tema "Flat"ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If (Alltrim(GetTheme()) == "FLAT").Or. SetMdiChild()
		nTam *= 0.90
	EndIf
EndIf
Return Int(nTam)
