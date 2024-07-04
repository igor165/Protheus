#include "VDFA170.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "HEADERGD.CH"
/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪哪目北
北矲uncao    ?VDFA170  ?Autor ?Everson S P Jr.       ?Data ?20/11/2013 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪拇北
北矰escri噮o ?Funcoes Manuten玢o de Aposentados e Pensionistas					潮?
潮?		?		 utilizadas pelo Modulo SigaVDF.         						潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北?Uso      ?Generico                                                          潮?
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北?             ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               潮北北北北?
北媚哪哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪目北
北砅rogramador   ?Data   ?PRJ/REQ-Chamado ? Motivo da Alteracao                       潮?
北媚哪哪哪哪哪哪呐哪哪哪哪拍哪哪哪哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北?   			 砐X/XX/XX砅RJ. x_xxxxx     硏xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa.潮?
北?             ?       砇EQ. xxxxxx      ?                                           潮
北滥哪哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Function VDFA170()
Local oBrowse
Local aIndexSRA		:= {}
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Local aFldRel		:= {"RA_NOME", "RA_RACACOR"}
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )
Private cCadastro	:= STR0001//'Manuten玢o de Aposentados e Pensionistas'
Private cGsPubl		:= GetMv( "MV_GSPUBL",,"1")

If cGsPubl == "2" .And. GetMv("MV_VDFLOGO",,"0") <> "0"
	cGsPubl := "3"
EndIf

If lBlqAcesso
	//"Dados Protegidos-Acesso Restrito"
	Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
	Break
EndIf

cFiltraRH	:= ChkRh( "GPEM040" , "SRA" , "1" )
cFiltraRH	+= If(!Empty(cFiltraRH),".AND. RA_CATFUNC =='9' .Or. RA_CATFUNC =='8' .Or. RA_CATFUNC == '7'",;
"RA_CATFUNC =='9' .Or. RA_CATFUNC =='8' .Or. RA_CATFUNC == '7'")
bFiltraBrw	:= { || FilBrowse( "SRA" , @aIndexSRA , @cFiltraRH ) }
Eval( bFiltraBrw )
mBrowse( 6, 1,22,75,"SRA",,,,,,fCriaCor())

Return
/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    矼enuDef() ?Autor ?Totvs	    ?Data ?20/11/2013         潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Novo model def para chamada da rotinha GPEA010            潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?                                                           潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Static Function MenuDef()
	Local aRotina := {}

	AAdd(aRotina, { STR0002, "Gpea010Vis", 0, 2})	 	   		//'Visualizar'
	AAdd(aRotina, { STR0003 ,"VDFINCPEN", 0, 3, 81}) //'Incluir Pensionista'
	AAdd(aRotina, { STR0004 , "Gpea010Alt", 0, 4, 82})	 	    //'Alterar'
	AAdd(aRotina, { STR0005 , "Gpea010Del", 0, 5, 3}) 	 	    //'Excluir'
	AAdd(aRotina, { STR0006 , "GpLegend",   0, 6, NIL, .F.})	//'Legenda'


Return aRotina

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    砎DFINCPEN ?Autor ?Totvs	    ?Data ?20/11/2013         潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Tela para selecionar servidor com motivo falecimento       潮?
潮?			 e Incluir um pensionista para o mesmo.	                  潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?                                                           潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function VDFINCPEN()
Local lRet    	:= .F.
Local bCancel 	:= {||fecha(oDlg)}
Local aVdfm210:= {}
Local oDlg
Local oGet1
Local oGet2
Private cMatPen	:= Space( TamSX3("RA_MAT")[1] )
Private cFilPen	:= Space( TamSX3("RA_FILIAL")[1] )

Begin Sequence


  DEFINE MSDIALOG oDlg TITLE 'Cadastro de Pensionistas' FROM 9,0 TO 22,67 OF oMainWnd

	@ 35,025 SAY STR0007 OF oDlg PIXEL//'Filial:'
	@ 35,062 MSGET oGet1 VAR cFilPen  PICTURE "@!" Valid (ExistCpo("SM0", cEmpAnt + cFilPen) ) F3 "XM0" SIZE 25,8 OF oDlg PIXEL HASBUTTON

	@ 50,025 SAY STR0008 PIXEL//'Matricula:'
	@ 50,062 MSGET oGet2 VAR cMatPen PICTURE "@!" Valid(VldFaleci(cFilPen,cMatPen)) F3 "SRAFAL" SIZE 29,8 OF oDlg PIXEL HASBUTTON

    @ 65,025 SAY STR0009 PIXEL 	     	     	  	//'Nome:'
    @ 65,062 MSGET IIF(cMatPen == '' ,'',Alltrim(Posicione('SRA',1,cFilPen+cMatPen,'RA_NOME'))) VALID {||oDlg:Refresh()} SIZE 90,8  OF oDlg Pixel WHEN .F.

   ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| (SRA->(dbSeek('@@@')),fecha(oDlg),Gpea010Inc("SRA")) },bCancel)

End Sequence


Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    砎ldFalec ?Autor ?Totvs	    ?Data ?20/11/2013         潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Valida se o servidor existe na filial e se esta com        潮?
潮?			 motivo da rescis鉶 igual S ou 9 falecimento                潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?                                                           潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Static Function VldFaleci(cFilPen,cMatPen)
Local lRet 		:= .F.

SRA->(dbSetOrder(1))
If SRA->(dbSeek(cFilPen+cMatPen))
	If SRA->RA_AFASFGT $ "S9S2"
		lRet := .T.
	Else
		MsgAlert(STR0010)//'O servidor selecionado n鉶 possui em seu cadastro o c骴igo de afastamento por falecimento (9 ou S)'
	EndIf
Else
	MsgAlert(STR0012+cFilPen+STR0011+cMatPen)	//' Matricula: '//'Servidor n鉶 Encontrado na Filial: '
EndIf


Return lRet

Static Function Fecha(oDlg)
	oDlg:End()
Return .T.