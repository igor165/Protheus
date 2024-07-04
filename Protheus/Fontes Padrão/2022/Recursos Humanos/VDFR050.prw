#include "VDFR050.CH"
#Include 'Protheus.ch'
#Include 'TopConn.ch'
#Include 'Report.Ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VDFR050    ³ Autor ³ Totvs                    ³ Data ³ 27/11/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio Certidao          .                                      ³±±
±±³          ³                                                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±±±±±±±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ¿±±
±±³Programador   ³ Data   ³ PRJ/REQ-Chamado ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivia F.      ³19/11/13³PRJ. M_RH001     ³-GSP-Rotina para seleção dos atos.          ³±±
±±³              ³        ³REQ. 002090      ³                               	         ³±±
±±³Marcos Pereira³13/01/15³				    ³-Ajuste para utilizar aTextoRet no For apos ³±±
±±³              ³        ³                 ³ a VD020AbreD                    	         ³±±
±±³              ³        ³                 ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//------------------------------------------------------------------------------
/*/ {Protheus.doc} VDFR050
Monta relatorio

@sample 	VDFR050(cTexto)

@param	    cTexto	texto que sera visualizado no editor

@author	Nivia Ferreira
@since		26/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFR050(cClass)
	Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
	Local aMsg			:= aOfusca[3]
	Local aFldRel		:= {"RA_NOME", "RA_RACACOR"}
	Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )
	Private cPerg   := "VDFR050"
	Private cMatAtu := SRA->(RA_FILIAL+RA_MAT)

	If !lBlqAcesso
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica as perguntas selecionadas                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If 	Pergunte(cPerg, .T.)
			Processa({|| VDFR50PROC(cClass)} ,"")
		Endif
	Else
		Help(" ",1,aMsg[1],,aMsg[2],1,0)
	Endif

Return()

//------------------------------------------------------------------------------
/*/ {Protheus.doc} VDFR50PROC
Seleciona todas a publicacoes

@sample 	VDFR50PROC(cClass)

@param	    cClass - classificao para o filtro

@author	Nivia Ferreira
@since		26/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFR50PROC(cClass)
Local aArea
Local aAreaSra
Local cQuery  := ''
Local aTexto  := {}
Local c1Assi  := ''
Local c2Assi  := ''
Local c1Cargo := ''
Local c2Cargo := ''
Local nResult := 0
Local nRAnos  := nRMeses := nRDias := 0
Local nA      := 0
Local dDataAtu:= date()

Private lSubsTp := "MSSQL" $ AllTrim( Upper( TcGetDb() ) ) .Or. AllTrim( Upper( TcGetDb() ) ) == 'SYBASE'

//Volta o posicionamento do SRA, pois o pergunte desposionou a tabela.
SRA->(dbseek(cMatAtu))

aArea   := GetArea()
aAreaSra:= SRA->(GetArea())

cQuery := " Select RI6_DTATPO,RI6_NUMDOC,RI6_ANO, RI6.R_E_C_N_O_ AS RECNO, RI5_DTATPO, "
If 	lSubsTp
	cQuery  += "SUBSTRING(RCC_CONTEU,1,3) 	AS Codigo, "
 	cQuery  += "SUBSTRING(RCC_CONTEU,04,30) AS Descr,"
	cQuery  += "SUBSTRING(RCC_CONTEU,34,20) AS Tipo, "
	cQuery  += "SUBSTRING(RCC_CONTEU,54,05) AS Sigla "
Else
	cQuery  += "SUBSTR(RCC_CONTEU,1,3)  AS Codigo, "
	cQuery  += "SUBSTR(RCC_CONTEU,04,30) AS Descr,"
	cQuery  += "SUBSTR(RCC_CONTEU,34,20) AS Tipo, "
	cQuery  += "SUBSTR(RCC_CONTEU,54,05) AS Sigla "
Endif

cQuery  += " FROM "+ RetSqlName( 'RI6' ) + " RI6, " + RetSqlName( 'RI5' ) + " RI5, " + RetSqlName( 'RCC' ) + " RCC "
cQuery  += " WHERE RI6.D_E_L_E_T_ = ' ' "
cQuery  += " AND  RI5.D_E_L_E_T_ = ' ' "
cQuery  += " AND  RCC.D_E_L_E_T_ = ' ' "
cQuery  += " AND  RCC_CODIGO='S100' "
cQuery  += " AND ( (RI6_FILMAT='" + SRA->RA_FILIAL +"' AND  RI6_MAT='"    + SRA->RA_MAT +"') or "
cQuery  += "       (RI6_FILSUB='" + SRA->RA_FILIAL +"' AND  RI6_MATSUB='" + SRA->RA_MAT +"') ) "
cQuery  += " AND  RI6_FILIAL=RI5_FILIAL"
cQuery  += " AND  RI6_TIPDOC=RI5_TIPDOC"
cQuery  += " AND  RI6_ANO=RI5_ANO"
cQuery  += " AND  RI6_NUMDOC=RI5_NUMDOC"
cQuery  += " AND  RI5_STATUS<>'4'"
cQuery  += " AND  RI6_CLASTP IN(" + cClass +")"
If 	lSubsTp
	cQuery  += " AND SUBSTRING(RCC_CONTEU,1,3) = RI6_TIPDOC "
Else
	cQuery  += " AND SUBSTR(RCC_CONTEU,1,3) = RI6_TIPDOC "
Endif
cQuery  += " AND RI6.RI6_DTATPO <> ' ' "
cQuery  += " AND RI6.RI6_ANO <> ' ' "
cQuery  += " AND RI6.RI6_STATUS IN('1','2','3') "
cQuery  += " ORDER BY RI5_DTATPO"
dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
dbSelectArea("TRB")

If 	!TRB->(EOF())
	aadd(aTexto,'<b><p style="text-align:Center">'+ STR0001 +' </p>')            //'C E R T I D Ã O'
	aadd(aTexto, '<br>')
	aadd(aTexto, '<p style="text-align:Justify">')
	aadd(aTexto, STR0002 + '</b>' + STR0003)                                         //'CERTIFICAMOS, 'a  pedido,  que  verificando  a  ficha  funcional  de '
	aadd(aTexto, Alltrim(SRA->RA_NOME) + STR0004 + Alltrim(SRA->RA_RG) + STR0005)    //', RG nº ' , ' e CPF nº '
	aadd(aTexto, Transform(SRA->RA_CIC,"@R 999.999.999-99") +STR0006)                //', constatamos o que segue:'
	aadd(aTexto, '</p>')
	aadd(aTexto, '<br>')

	While  TRB->(!EOF())
		aadd(aTexto, '<p style="text-align:Justify"><b>' + Alltrim(TRB->TIPO)+ STR0007 +TRB->RI6_NUMDOC+"/"+TRB->RI6_ANO+'-'+Alltrim(TRB->SIGLA)+', ' + '</b>') //' Nr '
		aadd(aTexto, STR0008)  //"datado de "
		aadd(aTexto, Transform(STOD(TRB->RI5_DTATPO),"@D"))
		aadd(aTexto, "-")

		dbSelectArea("RI6")
		dbGoTo(TRB->RECNO)
		aadd(aTexto, VDR50LIMP(RI6_TXTHIS))
	  	TRB->( dbSkip() )
	Enddo
	TRB->( dbCloseArea() )
	aadd(aTexto, '</p>')

	dbSelectArea("SQ3")
	DbSetOrder(1)
	DbSeek(FWXFILIAL("SQ3",SRA->RA_FILIAL)+SRA->RA_CARGO)

	aadd(aTexto, '<b>')
	aadd(aTexto, '<br>')
	aadd(aTexto, STR0009 + Alltrim(SQ3->Q3_DESCSUM) +':') //'Atividades do cargo '
	aadd(aTexto, '</b><br>')
	aadd(aTexto, '<pre>'+ MSMM(SQ3->Q3_DESCDET)+'</pre>')

	aadd(aTexto, '<br>')
	aadd(aTexto, '<br>')
	aadd(aTexto, '<p style="text-align:Justify">')
	aadd(aTexto, STR0010) //'Constatamos também que de '
	aadd(aTexto, Transform(SRA->RA_ADMISSA,"@D"))
	aadd(aTexto, STR0011) //' até a presente data o(a) servidor(a) conta com o tempo de  contribuição  de '
	nResult := (dDataAtu-SRA->RA_ADMISSA)+1

	aadd(aTexto, str(nResult))
	aadd(aTexto, ' (')
	aadd(aTexto,  LOWER(AllTrim(Extenso(nResult,.T.))))
	aadd(aTexto, STR0012)  //') dias, correspondendo  a  '

	fDias2Anos(nResult,@nRAnos,@nRMeses,@nRDias)

	aadd(aTexto, str(nRAnos)  +' ('+ if(nRAnos==0, 'zero',LOWER(AllTrim(Extenso(nRAnos,.T.))))  + ') ' + if(nRAnos==1 ,STR0034,STR0013) + ' ') //'ano,'###'anos,'
	aadd(aTexto, str(nRMeses) +' ('+ if(nRMeses==0,'zero',LOWER(AllTrim(Extenso(nRMeses,.T.)))) + ') ' + if(nRMeses==1,STR0035,STR0014) + ' ') //'mês e'###'meses e'
	aadd(aTexto, str(nRDias)  +' ('+ if(nRDias==0, 'zero',LOWER(AllTrim(Extenso(nRDias,.T.))))  + ') ' + if(nRDias==1 ,STR0036,STR0015) + ' ') //'dia.'###'dias.'

	If 	Day(dDataAtu) == 1
   		aadd(aTexto, STR0016) //' Ao primeiro dia do mês de'
	Else
	   	aadd(aTexto, STR0017) //' Aos '
   		aadd(aTexto, LOWER(AllTrim(Extenso(Day(dDataAtu),.T.)))+ STR0018) //' dias  do  mês  de  '
	Endif

	aadd(aTexto, '  ' + LOWER(MesExtenso(dDataAtu)) + STR0019)   // ' de '
	aadd(aTexto, LOWER(AllTrim(Extenso(Year(dDataAtu),.T.))))
	aadd(aTexto, ' ('+Transform( dDataAtu,"@D")+').')
	aadd(aTexto, '</p>')
	aadd(aTexto, '<br>')
	aadd(aTexto, '<br>')
	aadd(aTexto, '<br>')


	dbSelectArea("SRA")
	DbSetOrder(1)
	If DbSeek(MV_PAR01+MV_PAR02)
		c1Assi 	:= if(empty(SRA->RA_NOMECMP),SRA->RA_NOME,SRA->RA_NOMECMP)
		c1Cargo := alltrim(Posicione("SQ3",1,xFilial("SQ3",MV_PAR01)+SRA->RA_CARGO,"Q3_DESCSUM"))
    EndIf
	If DbSeek(MV_PAR03+MV_PAR04)
		c2Assi := if(empty(SRA->RA_NOMECMP),SRA->RA_NOME,SRA->RA_NOMECMP)
		c2Cargo := alltrim(Posicione("SQ3",1,xFilial("SQ3",MV_PAR03)+SRA->RA_CARGO,"Q3_DESCSUM"))
    EndIf

	aadd(aTexto, '<br>')
	aadd(aTexto, '<br>')
	aadd(aTexto, '<p style="text-align:Center"><b>' + c1Assi  + '</b></p>')
	aadd(aTexto, '<p style="text-align:Center">'    + c1Cargo + '</p>')
	aadd(aTexto, '<br>')
	aadd(aTexto, '<br>')
	aadd(aTexto, '<br>')
	aadd(aTexto, '<br>')
	aadd(aTexto, '<p style="text-align:Center"><b>' + c2Assi  + '</b></p>')
	aadd(aTexto, '<p style="text-align:Center">'    + c2Cargo + '</p>')
	aadd(aTexto, '<br>')
	aadd(aTexto, '<br>')

Else
	msgalert(STR0033) //"Não foi encontrada nenhuma publicação para o servidor selecionado."
	TRB->( dbCloseArea() )
Endif

RestArea( aAreaSRA )
If len(aTexto) > 0
	For nA := 1 to len(aTexto)
		aTexto[nA] := AcentHtml(aTexto[nA])
	Next nA
   VDR50EDIT(aTexto)
Endif

RestArea( aArea )
Return()


//------------------------------------------------------------------------------
/*/ {Protheus.doc} VDR50EDIT
Monta relatorio

@sample 	VDR50EDIT(aTexto)

@param	    aTexto	texto que sera visualizado no editor

@author	Nivia Ferreira
@since		26/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDR50EDIT(aTexto)
Local aArea   	:= GetArea()
Local var_Espera 	:= 0
Local nHandle    	:= ''
Local cArquivo   	:= SRA->RA_CIC
Local cLogoMP   	:= ''
Local aTextoRet     := {}
Local nA            := 0

Private cDir       	:= SUBSTR(GetTempPath(),1,3)
Private cLogo      	:= GetMV( "MV_VDFLOGO" )
Private cDiretorio 	:= cDir+GetMV( "MV_VDFPAST" )

If Empty(cLogo) .or. Empty(cDiretorio)
   MsgInfo(STR0024,STR0025) //"Preencha os parametros: MV_VDFPAST e MV_VDFLOGO" // "Atenção"
   Return()
Endif
VDF_Direct( cDiretorio, cDir, .T. ) //Rotina para criar pasta.
If 	!File(cDir+'LibreOffice\program\swriter.exe')
   	MsgInfo(STR0026) //'LibreOffice não esta gravado na pasta \LibreOffice\program\.'
   	Return()
Endif


If Empty(cLogo)
   MsgInfo(STR0027 , STR0025) //"Preencha os parametros: MV_VDFPAST e MV_VDFLOGO" // "Atenção"
   Return()
Endif

//Copia o logo do \system para c:
cLogoMP := "\inicializadores\"+ cLogo
IF FILE(cLogoMP)
	Delete File(cDiretorio + "\"+ cLogo)
	CPYS2T(cLogoMP,cDiretorio,.F.)
ENDIF

If File(cDiretorio +"\"+ cArquivo +".DOC")
	Delete File(cDiretorio+"\"+ cArquivo +".DOC")
Endif

aTextoRet := VD020AbreD(aTexto,'','','T',.t.)
nHandle:= FCREATE(cDiretorio+"\CERTIDAO.TXT")
FT_FUSE()
If nHandle <> -1
	For nA := 1 to len(aTextoRet)
		FWrite(nHandle, aTextoRet[nA])
	Next nA
	FClose(nHandle)
Endif

If !ExistDir(cDir+ GetMV("MV_VDFPAST"))
	MsgInfo(STR0022+cDir+STR0023)//'Não foi possivel abrir o documento, pasta '+//'Atos_Portarias não foi criada.'
Else
   //Winexec("localedef -v -c -i pt_BR -f UTF-8 pt_BR.UTF-8")
	If Frename(cDiretorio+"\CERTIDAO.TXT",cDiretorio+'\'+ cArquivo +".HTML") <> 0
		MsgInfo(STR0037+ cDiretorio+'\'+cArquivo +STR0038)//'O arquivo ' + cDiretorio+'\'+cArquivo + ' encontra-se reservado por outra sessão. Se persistir, reinicie o computador para liberar o arquivo.'

	Else
	    nRetT:=Winexec("\LibreOffice\program\swriter.exe  --invisible --convert-to doc "+cDiretorio+'\'+cArquivo+".HTML --outdir "+cDiretorio)

	    If nRetT == 0

			If MsgYesNo( STR0028 + cDiretorio+'\'+cArquivo + STR0029 ) //"Foi gerado o arquivo " # ".DOC.  Deseja abri-lo com o LibreOffice ? Certifique-se que todas as janelas do aplicativo estejam fechadas antes de prosseguir."

				//Espera que o Arquivo DOC seja criado*/
				For var_Espera := 1 To 50000
					If File(cDiretorio+'\'+cArquivo+".DOC")
						exit
					ElseIf var_Espera = 50000
						If !MsgYesNo(STR0030) //"A abertura está demorando mais do que o esperado. Deseja continuar aguardando ?"
					        exit
					 	Endif
					 var_Espera := 1
					Endif
				Next var_Espera

				If File(cDiretorio+'\'+cArquivo+".DOC")
					shellExecute( "Open", "\LibreOffice\program\soffice.exe", cDiretorio+'\'+cArquivo+".DOC" , cDiretorio, 1 )
				Else
					msgalert(STR0031+cDiretorio+'\'+cArquivo+STR0032) //"Não foi posssível gerar o arquivo " # ".DOC.  Contate a equipe de responsável pelo sistema."
				EndIf

			Endif

		Else

			msgalert(STR0031+cDiretorio+'\'+cArquivo+STR0032) //"Não foi posssível gerar o arquivo " # ".DOC.  Contate a equipe de responsável pelo sistema."

		Endif

	EndIf
EndIf


//Ecluindo arquivo
If File(cDiretorio + "\CERTIDAO.TXT")
	Delete File(cDiretorio + "\CERTIDAO.TXT")
Endif

If File(cDiretorio +"\"+ cArquivo +".HTML")
	Delete File(cDiretorio+"\"+ cArquivo +".HTML")
Endif

RestArea( aArea )
Return()



//------------------------------------------------------------------------------
/*/{Protheus.doc} VDR50LIMP
Limpeza do texto

@sample 	VDR50LIMP(cTexto)

@param	    cTexto	texto que sera visualizado no editor

@author	Nivia Ferreira
@since		26/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDR50LIMP(cTexto)

cTroca1 :='<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN" "http://www.w3.org/TR/REC-html40/strict.dtd">'
cTroca2 :='<html><head><meta name="qrichtext" content="1" /><style type="text/css">'
cTroca3 :='p, li { white-space: pre-wrap; }'
cTroca4 :='</style></head><body style=" font-family:'+'Arial'+'; font-weight:400; font-style:normal;">'
cTroca5 :='<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;">'
cTroca6 :='<p style=" margin-top:12px; margin-bottom:12px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;">'
cTroca7 :='<span style=" font-weight:600;"> </span></p></body></html>'

cTexto := AllTrim(STRTRAN ( cTexto , cTroca1  , '' , , ))
cTexto := AllTrim(STRTRAN ( cTexto , cTroca2  , '' , , ))
cTexto := AllTrim(STRTRAN ( cTexto , cTroca3  , '' , , ))
cTexto := AllTrim(STRTRAN ( cTexto , cTroca4  , '' , , ))
cTexto := AllTrim(STRTRAN ( cTexto , cTroca5  , '' , , ))
cTexto := AllTrim(STRTRAN ( cTexto , cTroca6  , '' , , ))
cTexto := AllTrim(STRTRAN ( cTexto , cTroca7  , '' , , ))

Return(cTexto)