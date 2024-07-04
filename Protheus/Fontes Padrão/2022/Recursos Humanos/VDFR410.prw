#Include 'Protheus.ch'
#Include 'TopConn.ch'
#Include 'Report.Ch'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VDFR410.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFR410
Declaração, Certidão e Certificado de Estagiários
@owner Everson S P
@author Everson S P
@since 13/02/2013
@version P11
/*/
//------------------------------------------------------------------------------
Function VDFR410()
	Local oBrowse
	Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
	Local aMsg			:= aOfusca[3]
	Local aFldRel		:= {"RA_NOME", "RA_RACACOR"}
	Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )

	if !lBlqAcesso
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('SRA')
		oBrowse:SetDescription(OemToAnsi(STR0001))//'Declaração, Certidão e Certificado de Estagiário'
		oBrowse:SetFilterDefault( "RA_CATFUNC $ 'E,G'")
		oBrowse:DisableDetails()
		oBrowse:AddLegend( "Empty(RA_SITFOLH)"	,"GREEN"	, OemToAnsi(STR0002)) //'Situação Normal'
		oBrowse:AddLegend( "RA_SITFOLH == 'D'"	,"Red"		, OemToAnsi(STR0003)) //'Desligado'
		oBrowse:AddLegend( "RA_SITFOLH == 'A'"	,"YELLOW"	, OemToAnsi(STR0004)) //'Afastado'
		oBrowse:AddLegend( "RA_SITFOLH == 'F'"	,"Blue"		, OemToAnsi(STR0005)) //'Ferias'
		oBrowse:Activate()
	Else
		Help(" ",1,aMsg[1],,aMsg[2],1,0)
		Return
	Endif

Return NIL

//-------------------------------------------------------------------
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE OemToAnsi(STR0006)	ACTION 'VDFR410A()' OPERATION 2 ACCESS 0 //'Emitir Documento'

Return aRotina


//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFR410A

@owner Everson S P
@author Everson S P
@since 13/02/2013
@version P11
/*/
//------------------------------------------------------------------------------
Function VDFR410A()
Local aArea 		:= GetArea()
Local aRet 			:= {}
Local aCombo 		:= {"",OemToAnsi(STR0007),OemToAnsi(STR0008),OemToAnsi(STR0009)} //1-DECLARAÇÃO##2-CERTIFICADO##3-CERTIDÃO
Local aParamBox 	:= {}
Local cTexto		:= ""
Local cLogo			:= ""
Local cMatEstagi	:= SRA->RA_MAT
Local cFilEstagi	:= SRA->RA_FILIAL
Local lContinua		:= .f.
Local cComarca		:= Posicione("SQB",1,FwxFilial("SQB")+SRA->RA_DEPTO,"QB_COMARC")
Local cTxtPadrao 	:= OemToAnsi("nos termos do artigo 21, Parágrafo único da Resolução nº 033/2009CPJ") //"nos termos do artigo 21, Parágrafo único da Resolução nº 002 - CPJ/2009"
Local oDlgWizard

Private cNomeEstagi	:= if(!empty(SRA->RA_NOMECMP),SRA->RA_NOMECMP,SRA->RA_NOME)
Private cHrasTrab	:= SRA->RA_HRSEMAN
Private dDemissa	:= if(empty(SRA->RA_DEMISSA),ctod("//"),SRA->RA_DEMISSA-1)
Private cCPF		:= SRA->RA_CIC

Private dDataEfei	:= ctod("//")
Private dDataPubl	:= ctod("//")
Private cNumDoc     := space(05)
Private cAno        := space(04)
Private cDesComarc	:= Posicione("REC",1,FwxFilial("REC")+cComarca,"REC_NOME")
Private cTipoDoc    := space(03)
Private cSigla      := space(05)

//Busca informacoes do credenciamento
RI5->( DbSetOrder(1) )
RI6->( DbSetOrder(1) )
If RI6->( DbSeek( FwxFilial("RI6") + "REY" + cCPF + cFilEstagi + cMatEstagi ) )
	While !lContinua .and. RI6->( !EOF() ) .And. RI6->( RI6_TABORI + RI6_CPF + RI6_FILMAT + RI6_MAT ) == "REY" + cCPF + cFilEstagi + cMatEstagi
		If RI6->RI6_CLASTP $ '24'
			If !Empty(RI6->RI6_NUMDOC)
				If RI5->(DbSeek(FwxFilial("RI5")+RI6->(RI6_ANO+RI6_NUMDOC+RI6_TIPDOC)))
					If !Empty(RI5->RI5_DTAPUB)
						dDataEfei := RI6->RI6_DTEFEI
						dDataPubl := RI5->RI5_DTAPUB
						cNumDoc   := RI6->RI6_NUMDOC
						cAno      := RI6->RI6_ANO
						cTipoDoc  := Alltrim( fDescRCC( "S100",RI5->RI5_TIPDOC,1,3,34,20 ) )
						cSigla    := Alltrim( fDescRCC( "S100",RI5->RI5_TIPDOC,1,3,54,5 ) )
						lContinua := .T.
					EndIF
				EndIf
			EndIF
		EndIf
		RI6->(dbskip())
	EndDo
EndIf

If empty(dDataEfei)
	dDataEfei := SRA->RA_ADMISSA
EndIf

If !lContinua
	//"O Estagiário não possui publicação de credenciamento de estagiários.
	//Deseja continuar e completar manualmente as informações diretamente no documento, após gerado pelo sistema ?"
	lContinua := MsgYesNo(OemToAnsi(STR0011))
EndIf

If lContinua
	aAdd(aParamBox,{02,OemToAnsi(STR0012),"",aCombo,70,"!Vazio()",.T.})//"Tipo de Documento //Numerico
	aAdd(aParamBox,{01,OemToAnsi(STR0013),Space(TamSX3("RA_FILIAL")[1]),"","","SM0","'3' $ MV_PAR01",0,.F.}) //Fil. Responsável
	aAdd(aParamBox,{01,OemToAnsi(STR0014),Space(TamSX3("RA_MAT")[1]),"","","SRA","'3' $ MV_PAR01",0,.F.}) //Mat. Responsável
	aAdd(aParamBox,{01,OemToAnsi(STR0015),Space(TamSX3("RA_FILIAL")[1]),"","","SM0"," !Empty(MV_PAR01)",0,.F.}) //Fil. Assinatura // Tipo caractere
	aAdd(aParamBox,{01,OemToAnsi(STR0016),Space(TamSX3("RA_MAT")[1]),"","","SRA","!Empty(MV_PAR01)",0,.F.}) //Mat. Assinatura
	aAdd(aParamBox,{01,OemToAnsi(STR0017),Space(TamSX3("RA_FILIAL")[1]),"","","SM0","'1' $ MV_PAR01",0,.F.}) //Fil. Assinatura 2
	aAdd(aParamBox,{01,OemToAnsi(STR0018),Space(TamSX3("RA_MAT")[1]),"","","SRA","'1' $ MV_PAR01",0,.F.}) //Mat. Assinatura 2
	aAdd(aParamBox,{11,OemToAnsi(STR0019),OemToAnsi(cTxtPadrao),".T.","'2' $ MV_PAR01",.F.}) //Texto Base Legal

	If ParamBox(aParamBox,OemToAnsi(STR0020),@aRet,{||VldOK(aRet)},,,,,,,) //"Dados para Impressão"
		cTexto := GeraHTML(@cLogo,aRet,'1')//Recebe o Html que deve imprimir no .Doc
		Processa({|| VDFRHTML(cTexto,cLogo)} ,"")
	EndIf
EndIf
RestArea(aArea)
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFRHTML
Gera o HTML para o LibreOffice da Declaração de estagiario.
@sample 	VDFRHTML(cClass)
@param	    cHtml - C
@author	Everson S P Junior
@since		11/02/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function VDFRHTML(cTexto,cLogo)
Local nHandle    	:= ''
Local var_Espera 	:= 	0
Local cArquivo		:= 'estagiario_'+If("1" $ MV_PAR01,'declaracao_',If("2" $ MV_PAR01,'certificado_','certidao_'))+cCPF
Local lAchou		:= .F.
Local cDir			:= SUBSTR(GetTempPath(),1,3)
Local cDiretorio	:= cDir + GetMV( "MV_VDFPAST",,"" ) //DIRETORIO RELATORIO_ESTAGIARIO // Ultilizar o diretorio temp do Usuario
Local cLogoMP       := "\inicializadores\" + StrTran(StrTran(cLogo,".png",""),".PNG","") + "01.PNG"
Local cLogoMP2      := "\inicializadores\" + StrTran(StrTran(cLogo,".png",""),".PNG","") + "02.PNG"

Default cTexto := OemToAnsi(STR0021) // "ERRO NA GERAÇÃO!"

If FILE(cLogoMP)
	Delete File(cDiretorio + "\" + StrTran(StrTran(cLogo,".png",""),".PNG","") + "01.PNG")
	CPYS2T("\inicializadores\" + StrTran(StrTran(cLogo,".png",""),".PNG","") + "01.PNG",cDiretorio,.F.)
EndIf

If FILE(cLogoMP2)
	Delete File(cDiretorio + "\" + StrTran(StrTran(cLogo,".png",""),".PNG","") + "02.PNG")
	CPYS2T("\inicializadores\" + StrTran(StrTran(cLogo,".png",""),".PNG","") + "02.PNG",cDiretorio,.F.)
EndIf

If File(cDiretorio +"\"+ cArquivo +".DOC")
	Delete File(cDiretorio+"\"+ cArquivo +".DOC")
	Delete File(cDiretorio+"\"+ cArquivo +".TXT")
Endif

nHandle:= FCREATE(cDiretorio+"\"+ cArquivo +".TXT")
FT_FUSE()
If nHandle <> -1
	FWrite(nHandle, cTexto)
	FClose(nHandle)
Endif

   //Winexec("localedef -v -c -i pt_BR -f UTF-8 pt_BR.UTF-8")
	Frename(cDiretorio+"\"+cArquivo+".TXT",cDiretorio+'\'+ cArquivo +".HTML")
    nRetT:=Winexec("\LibreOffice\program\swriter.exe  --invisible --convert-to doc "+cDiretorio+'\'+cArquivo+".HTML --outdir "+cDiretorio)

    If nRetT == 0
		While !lAchou .AND. IIF(var_Espera == 0,.T.,MsgYesNo(OemToAnsi(STR0022))) //"A abertura está demorando mais que o esperado. Deseja continuar aguardando?"
			//Espera que o Arquivo de Resposta Seja Criado*/
			For var_Espera := 1 To 100000
				If File(cDiretorio+'\'+cArquivo+".DOC")
					lAchou := .T.
					Exit
				Endif
			Next var_Espera
		EndDo

		shellExecute( "Open", "\LibreOffice\program\soffice.exe",cDiretorio+'\'+cArquivo+".DOC", "C:\", 1 )
	Endif

If File(cDiretorio +"\"+ cArquivo +".Html")
	Delete File(cDiretorio+"\"+ cArquivo +".Html")
Endif


Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFRHTML
Gera o HTML para o LibreOffice da Declaração de estagiario.
@sample 	GeraHTML(cLogo,aPerg,cTipo)
@param	    cHtml - C
@author	Everson S P Junior
@since		11/02/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function GeraHTML(cLogo,aPerg,cTipo)
Local AareaSRA	:= SRA->(GetArea())
Local cNomeRespo	:=	Posicione('SRA',1,APERG[2]+APERG[3],"RA_NOMECMP")
Local cCargoResp	:= 	Posicione('SQ3',1,FWxFilial("SQ3")+SRA->RA_CARGO,"Q3_DESCSUM")
Local cNomeAssi1	:=	Posicione('SRA',1,APERG[4]+APERG[5],"RA_NOMECMP")
Local cCargo1		:= 	Posicione('SQ3',1,FWxFilial("SQ3")+SRA->RA_CARGO,"Q3_DESCSUM")
Local cNomeAssi2	:= 	Posicione('SRA',1,APERG[6]+APERG[7],"RA_NOMECMP")
Local cCargo2		:= 	Posicione('SQ3',1,FWxFilial("SQ3")+SRA->RA_CARGO,"Q3_DESCSUM")
Local cLocal		:=  AcentHtml(SuperGetMv("MV_VDCERT1",,"")) //MINISTÉRIO PÚBLICO DO ESTADO DE MATO GROSSO
Local cLocal2		:=  AcentHtml(SuperGetMv("MV_VDCERT2",,"")) //Procuradoria-Geral de Justica
Local cDescDpto	:= IIF(Empty(Alltrim(SQB->QB_DESCRIC)),'1&deg;' +CRLF+'Promotoria de Justi&ccedil;a C&iacute;vel', Alltrim(SQB->QB_DESCRIC))
Local cTextoPar	:= APERG[8]
Local cHtml	:= ''

cNomeRespo	:=	if(!empty(cNomeRespo),cNomeRespo,Posicione('SRA',1,APERG[2]+APERG[3],"RA_NOME"))
cNomeAssi1	:=	if(!empty(cNomeAssi1),cNomeAssi1,Posicione('SRA',1,APERG[4]+APERG[5],"RA_NOME"))
cNomeAssi2	:= 	if(!empty(cNomeAssi2),cNomeAssi2,Posicione('SRA',1,APERG[6]+APERG[7],"RA_NOME"))

If left(APERG[1],1) == "1" // HTML Da DECLARaÇÃO
	cLogo := GetMV( "MV_LOGDECL",,"" ) // Nome do Logo para o documento da declaração do estagio
	cHTML += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">' +CRLF
	cHTML += '<html>' +CRLF
	cHTML += '<head>' +CRLF
	cHTML += '<meta http-equiv="content-type" content="text/html; charset=windows-1252">' +CRLF
	cHTML += '<title></title>' +CRLF
	cHTML += '<meta name="generator" content="LibreOffice 4.2.0.4 (Windows)">' +CRLF
	cHTML += '<meta name="created" content="20140211;0">' +CRLF
	cHTML += '<meta name="changed" content="20140214;114201647000000">' +CRLF
	cHTML += '</head>' +CRLF
	cHTML += '<BODY LANG="pt-BR" TEXT="#000000" LINK="#000080" VLINK="#800000" DIR="LTR">' +CRLF
	cHTML += "		<p align='center'>" + CRLF
	cHTML += "			<img src='" + StrTran(StrTran(cLogo,".png",""),".PNG","") + "01.PNG' name='Figura1' align='middle' width='643' height='77' border='0'/>" + CRLF
	cHTML += "		</p>" + CRLF
	cHTML += '<p><br><br>' +CRLF
	cHTML += '</p>' +CRLF
	cHTML += '<p><br><br>' +CRLF
	cHTML += '</p>' +CRLF
	cHTML += '<p><br><br>' +CRLF
	cHTML += '</p>' +CRLF
	cHTML += '<p><br><br>' +CRLF
	cHTML += '</p>' +CRLF
	cHTML += '<p><br><br>' +CRLF
	cHTML += '</p>' +CRLF
	cHTML += '<p><br><br>' +CRLF
	cHTML += '</p>' +CRLF
	cHTML += '<p align="center"><font size="6" style="font-size: 26pt"><b>DECLARA&Ccedil;&Atilde;O</b></font></p>' +CRLF
	cHTML += '<p align="center"><br><br>' +CRLF
	cHTML += '</p>' +CRLF
	cHTML += '<p align="justify" style="background: #ffffff"><font size="4" style="font-size: 16pt"><b>Declaramos,</b></font><font size="4" style="font-size: 16pt">' +CRLF
	cHTML += 'para os devidos fins, que </font><font size="4" style="font-size: 16pt"><b>'+Alltrim(cNomeEstagi)+'</b></font><font size="4" style="font-size: 16pt"> &eacute;' +CRLF
	cHTML += 'estagi&aacute;rio(a) deste &Oacute;rg&atilde;o P&uacute;blico, tendo' +CRLF
	cHTML += 'sido credenciado(a) pelo(a) '+cTipoDoc+' n&deg; </font><font size="4" style="font-size: 16pt"><b>'+Alltrim(cNumDoc)+'/'+Alltrim(cAno)+'-'+cSigla+',' +CRLF
	cHTML += '</b></font><font size="4" style="font-size: 16pt"> D.O. de '+dToc(dDataPubl)+',' +CRLF
	cHTML += ' em virtude de ser' +CRLF
	cHTML += 'aprovado(a) no exame de sele&ccedil;&atilde;o de credenciamento de' +CRLF
	cHTML += 'Estagi&aacute;rios, para exercer suas atribui&ccedil;&otilde;es' +CRLF
	cHTML += 'na Comarca de </font><font size="4" style="font-size: 16pt"><b>'+Alltrim(cDesComarc)+',' +CRLF
	cHTML += '</b></font><font size="4" style="font-size: 16pt"> a partir de' +CRLF
	cHTML += '</font><font size="4" style="font-size: 16pt"><b>'+dToc(dDataEfei)+'</b></font><font size="4" style="font-size: 16pt">,' +CRLF
	cHTML += 'com jornada de trabalho de '+Alltrim(STR(cHrasTrab)) +' ('+AllTRim(Extenso(cHrasTrab,.T.))+') horas semanais.</font></p>' +CRLF
	cHTML += '<p align="center"><font size="4" style="font-size: 16pt">Por ser' +CRLF
	cHTML += 'verdade, firmamos a presente.                                        <br><br>' +CRLF
	cHTML += ''+Alltrim(SM0->M0_CIDENT)+'-'+Alltrim(SM0->M0_ESTENT)+', <b>'+STRZERO(Day(dDataBase),2)+ " de "+MesExtenso(dDataBase)+" de "+STRZERO(Year(dDataBase),4)+'</b></font></p>' +CRLF
	cHTML += '<p><br><br>' +CRLF
	cHTML += '</p>' +CRLF
	cHTML += '<p><br><br>' +CRLF
	cHTML += '</p>' +CRLF
	cHTML += '<p align="center"><b>'+Alltrim(cNomeAssi1)+'                                 <br><br>' +CRLF
								 cHTML += '' +CRLF
	cHTML += '</b><font size="1" style="font-size: 8pt">'+AllTrim(cCargo1)+'</font></p>' +CRLF
	cHTML += '<p>Visto.</p>' +CRLF
	cHTML += '<p><br><br>' +CRLF
	cHTML += '</p>' +CRLF
	cHTML += '<p align="center"><b>'+Alltrim(cNomeAssi2)+'                                 <br><br>' +CRLF
								 cHTML += '' +CRLF
	cHTML += '</b><font size="1" style="font-size: 8pt">'+AllTrim(cCargo2)+'</font></p>' +CRLF
	cHTML += '<p><br><br>' +CRLF
	cHTML += '</p>' +CRLF
	cHTML += "		<p align='center' style='margin-bottom: 0cm'>" + CRLF
	cHTML += "			<img src='" + StrTran(StrTran(cLogo,".png",""),".PNG","") + "02.PNG' name='Figura2' align='bottom' width='648' height='80' border='0'/>" + CRLF
	cHTML += "		</p>" + CRLF
	cHTML += '</body>' +CRLF
	cHTML += '</html>' +CRLF
ElseIf left(APERG[1],1) == "2" // HTML do CERTIFICADO
	cLogo := GetMV( "MV_LOCERTI",,"" ) // Nome do Logo para o documento da declaração do estagio
	cHTML += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">' +CRLF
	cHTML += '<HTML>' +CRLF
	cHTML += '<HEAD>' +CRLF
	cHTML += '<META HTTP-EQUIV="CONTENT-TYPE" CONTENT="text/html; charset=windows-1252">' +CRLF
	cHTML += '<TITLE></TITLE>' +CRLF
	cHTML += '<META NAME="GENERATOR" CONTENT="LibreOffice 4.0.1.2 (Windows)">' +CRLF
	cHTML += '<META NAME="CREATED" CONTENT="20140212;15235759">' +CRLF
	cHTML += '<META NAME="CHANGED" CONTENT="20140212;16413675">' +CRLF
	cHTML += '<STYLE TYPE="text/css">' +CRLF
	cHTML += '<!--' +CRLF
	cHTML += '@page { size: 29.7cm 21cm; margin-left: 2.51cm; margin-right: 2.63cm; margin-top: 2cm; margin-bottom: 1.99cm }' +CRLF
	cHTML += 'P { margin-bottom: 0.21cm; color: #000000 }' +CRLF
	cHTML += 'A:link { color: #000080; so-language: zxx; text-decoration: underline }' +CRLF
	cHTML += 'A:visited { color: #800000; so-language: zxx; text-decoration: underline }' +CRLF
	cHTML += '-->' +CRLF
	cHTML += '</STYLE>' +CRLF
	cHTML += '</HEAD>' +CRLF
	cHTML += '<BODY LANG="pt-BR" TEXT="#000000" LINK="#000080" VLINK="#800000" BACKGROUND="'+AllTrim(cLogo)+'" DIR="LTR">' +CRLF
	cHTML += '<p><br><br>' +CRLF
	cHTML += '</p>' +CRLF
	cHTML += '<p><br><br>' +CRLF
	cHTML += '</p>' +CRLF
	cHTML += '<P ALIGN=CENTER STYLE="margin-bottom: 0cm"><FONT SIZE=6><B>'+alltrim(cLocal)+' </B></FONT>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=CENTER STYLE="margin-bottom: 0cm"><FONT SIZE=6><B>'+alltrim(cLocal2)+'</B></FONT></P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=CENTER STYLE="margin-bottom: 0cm"><FONT SIZE=7 STYLE="font-size: 32pt"><B>CERTIFICADO</B></FONT></P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0cm"><FONT SIZE=5><B>O' +CRLF
	cHTML += ''+Alltrim(cCargo1)+', </B><SPAN STYLE="font-weight: normal">'+Alltrim(cTextoPar)+', certifica que </SPAN><B>'+Alltrim(cNomeEstagi)+'' +CRLF
	cHTML += '</B><SPAN STYLE="font-weight: normal">estagiou no </SPAN><SPAN STYLE="font-weight: normal"> '+Alltrim(cLocal)+', junto &agrave; '
	cHTML +=  cDescDpto + ' da Comarca de </SPAN><B>'+Alltrim(cDesComarc)+', </B><SPAN STYLE="font-weight: normal">no período de' +CRLF
	cHTML += '</SPAN><B>'+dToc(dDataEfei)+'</B> <SPAN STYLE="font-weight: normal">a </SPAN><B>'+dToc(dDemissa)+'.</B></FONT></P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=RIGHT STYLE="margin-bottom: 0cm"><FONT SIZE=4 STYLE="font-size: 16pt"><B>'+Alltrim(SM0->M0_CIDENT)+', '+STRZERO(Day(dDataBase),2)+' de '+MesExtenso(dDataBase)+' de '+STRZERO(Year(dDataBase),4)+'</B></FONT></P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=CENTER STYLE="margin-bottom: 0cm"><FONT SIZE=4 STYLE="font-size: 16pt"><B>'+Alltrim(cNomeAssi1)+' </B></FONT>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=CENTER STYLE="margin-bottom: 0cm"><FONT SIZE=4 STYLE="font-size: 14pt"><B>'+Alltrim(cCargo1)+' </B></FONT>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '</BODY>' +CRLF
	cHTML += '</HTML>' +CRLF
ElseIf left(APERG[1],1) == "3" // Certidão para o estagiario
	cLogo := GetMV( "MV_LOGDECL",,"" ) // Nome do Logo para o documento da declaração do estagio
	cHTML += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">' +CRLF
	cHTML += '<HTML>' +CRLF
	cHTML += '<HEAD>' +CRLF
	cHTML += '<META HTTP-EQUIV="CONTENT-TYPE" CONTENT="text/html; charset=windows-1252">' +CRLF
	cHTML += '<TITLE></TITLE>' +CRLF
	cHTML += '</HEAD>' +CRLF
	cHTML += '<BODY LANG="pt-BR" LINK="#000080" VLINK="#800000" DIR="LTR">' +CRLF
	cHTML += "		<p align='center'>" + CRLF
	cHTML += "			<img src='" + StrTran(StrTran(cLogo,".png",""),".PNG","") + "01.PNG' name='Figura1' align='middle' width='643' height='77' border='0'/>" + CRLF
	cHTML += "		</p>" + CRLF
	cHTML += '<P STYLE="margin-bottom: 0cm"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P STYLE="margin-bottom: 0cm"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=CENTER STYLE="margin-bottom: 0cm"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=CENTER STYLE="margin-bottom: 0cm"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=CENTER STYLE="margin-bottom: 0cm"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=CENTER STYLE="margin-bottom: 0cm"><FONT SIZE=6 STYLE="font-size: 26pt"><B>CERTID&Atilde;O</B></FONT></P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm; font-weight: normal"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm; font-weight: normal"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm; font-weight: normal"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0cm; font-weight: normal"><FONT SIZE=4 STYLE="font-size: 16pt"><B>Certifico</B>,' +CRLF
	cHTML += 'para os devidos fins, que <B>'+Alltrim(cNomeEstagi)+'</B>,' +CRLF
	cHTML += '&eacute; estagi&aacute;rio(a) deste Org&atilde;o P&uacute;blico, tendo sido' +CRLF
	cHTML += 'credenciado(a) pelo(a) '+cTipoDoc+' n&deg; '+Alltrim(cNumDoc)+'/'+Alltrim(cAno)+' &ndash; '+cSigla+', D.O. de '+dToc(dDataPubl)+',' +CRLF
	cHTML += 'em virtude de ser aprovado(a) no Exame de Sele&ccedil;&atilde;o de' +CRLF
	cHTML += 'Credenciamento de Estagi&aacute;rios, para exercer suas atribui&ccedil;&otilde;es' +CRLF
	cHTML += 'na Comarca de '+Alltrim(cDesComarc)+', a partir de '+dToc(dDataEfei)+', com' +CRLF
	cHTML += 'atividades de '+Alltrim(STR(cHrasTrab))+' ('+AllTRim(Extenso(cHrasTrab,.T.))+') horas semanais. O referido &eacute;' +CRLF
	cHTML += 'verdade, disso dou f&eacute;, em virtude do que eu <B>'+Alltrim(cNomeRespo)+'</B> , '+Alltrim(cCargoResp)+', lavrei a presente Certid&atilde;o, que vai assinada pelo(a)' +CRLF
	cHTML += ''+Alltrim(cCargo1)+', '+Alltrim(cNomeAssi1)+',  na data de '+STRZERO(Day(dDataBase),2)+ " de "+MesExtenso(dDataBase)+" de "+STRZERO(Year(dDataBase),4)+'.</FONT></P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm; font-weight: normal"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm; font-weight: normal"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm; font-weight: normal"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm; font-weight: normal"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm; font-weight: normal"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm; font-weight: normal"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm; font-weight: normal"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm; font-weight: normal"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=LEFT STYLE="margin-bottom: 0cm; font-weight: normal"><BR>' +CRLF
	cHTML += '</P>' +CRLF
	cHTML += '<P ALIGN=CENTER STYLE="margin-bottom: 0cm"><FONT SIZE=2 STYLE="font-size: 16pt"><B>'+Alltrim(cNomeAssi1)+'</B></FONT></P>' +CRLF
	cHTML += '<P ALIGN=CENTER STYLE="margin-bottom: 0cm; font-weight: normal"><FONT SIZE=2>'+Alltrim(cCargo1)+'</FONT></P>' +CRLF
	cHTML += "		<p align='center' style='margin-bottom: 0cm'>" + CRLF
	cHTML += "			<img src='" + StrTran(StrTran(cLogo,".png",""),".PNG","") + "02.PNG' name='Figura2' align='bottom' width='648' height='80' border='0'/>" + CRLF
	cHTML += "		</p>" + CRLF
	cHTML += '</BODY>' +CRLF
	cHTML += '</HTML>' +CRLF
EndIf
RestArea(AareaSRA)
Return cHtml


//------------------------------------------------------------------------------
/*/{Protheus.doc} VldOK
Valida os campos do Parambox.
@sample 	VDFRHTML(cClass)
@param	    lRet
@author	Everson S P Junior
@since		17/02/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function VldOK(APERG,oDlgWizard)
Local lRet	:= .T.

If Empty(MV_PAR01)
	MsgAlert(OemToAnsi(STR0023)) //"O campo Tipo de Documento não pode ser Vazio!"
	lRet	:= .F.
EndIF

If lRet
	If "1" $ MV_PAR01
		If Empty(MV_PAR04)
			MsgAlert(OemToAnsi(STR0024)) //"Preencher o campo Fil. Assinatura"
			lRet	:= .F.
		EndIf
		If Empty(MV_PAR05)
			MsgAlert(OemToAnsi(STR0025)) //"Preencher o campo Mat. Assinatura"
			lRet	:= .F.
		EndIf
		If Empty(MV_PAR06)
			MsgAlert(OemToAnsi(STR0026)) //"Preencher o campo Fil. Assinatura 2"
			lRet	:= .F.
		EndIf
		If Empty(MV_PAR07)
			MsgAlert(OemToAnsi(STR0027)) //"Preencher o campo Mat. Assinatura 2"
			lRet	:= .F.
		EndIf

	ElseIf "2" $ APERG[1]
		If Empty(MV_PAR04)
			MsgAlert(OemToAnsi(STR0024)) //"Preencher o campo Fil. Assinatura"
			lRet	:= .F.
		EndIf
		If Empty(MV_PAR05)
			MsgAlert(OemToAnsi(STR0025)) //"Preencher o campo Mat. Assinatura"
			lRet	:= .F.
		EndIf
		If Empty(MV_PAR08)
			MsgAlert(OemToAnsi(STR0028)) //"Preencher o campo Texto Base Legal"
			lRet	:= .F.
		EndIf
	ElseIf "3" $ APERG[1]
		If Empty(MV_PAR02)
			MsgAlert(OemToAnsi(STR0029)) //"Preencher o campo Fil. Responsável"
			lRet	:= .F.
		EndIf
		If Empty(MV_PAR03)
			MsgAlert(OemToAnsi(STR0030)) //"Preencher o campo Mat. Responsável"
			lRet	:= .F.
		EndIf
		If Empty(MV_PAR04)
			MsgAlert(OemToAnsi(STR0024)) //"Preencher o campo Fil. Assinatura"
			lRet	:= .F.
		EndIf
		If Empty(MV_PAR05)
			MsgAlert(OemToAnsi(STR0025)) //"Preencher o campo Mat. Assinatura"
			lRet	:= .F.
		EndIf
	Else

	EndIf
EndIf
Return lRet
