// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 03     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINMT01.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |  OFINMT01  | Autor | Luis Delorme          | Data | 12/06/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Exportação dos Arquivo DEF - Mitsubishi                      |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINMT01()
//
Local aSay := {}
Local aButton := {}

Private cDesc1  := STR0001
Private cDesc2  := STR0002
Private cDesc3  := STR0003

Private cTitulo := "OFINMT01"
Private cPerg := "ONMT01"
Private lErro := .f.  	    // Se houve erro, não move arquivo gerado
Private cArquivo			// Nome do Arquivo a ser importado
Private aLinhasRel := {}	// Linhas que serão apresentadas no relatorio
//
CriaSX1()
//
aAdd( aSay, cDesc1 ) // Um para cada cDescN
aAdd( aSay, cDesc2 ) // Um para cada cDescN
aAdd( aSay, cDesc3 ) // Um para cada cDescN
//
nOpc := 0
aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T. )    }} )
aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )
//
FormBatch( cTitulo, aSay, aButton )
//
If nOpc <> 1
	Return
Endif
//
Pergunte(cPerg,.f.)
//
RptStatus( {|lEnd| ExportArq(@lEnd)},STR0004,STR0005)
//
if !lErro
	RptStatus({|lEnd| ImprimeRel(@lEnd) },STR0004, STR0006, .T. )
endif
//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | ExportArq  | Autor | Luis Delorme          | Data | 12/06/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Exportação do Arquivo                                        |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ExportArq()
//
Local aVetNome := {}
Local aVetTam := {}
Local aVetData := {}
Local aVetHora := {}
//
//#############################################################################
//# Tenta abrir o arquivo texto                                               #
//#############################################################################
cArquivo := "DEF_"+STRZERO(Year(MV_PAR03),4)+STRZERO(Month(MV_PAR03),2)+".TXT"
//
if aDir( Alltrim(MV_PAR01)+cArquivo ,aVetNome,aVetTam,aVetData,aVetHora) > 0
	if !MsgYesNo(STR0007,STR0008)
		lErro := .t.
		return
	endif
endif
//
nHnd := FCREATE(Alltrim(MV_PAR01)+Alltrim(cArquivo),0)
//
cQryAlias := GetNextAlias()


cQuery := "SELECT VD9.VD9_CODCON, VD9.VD9_CPODEF, VD9.VD9_CONCTA, VDC.VDC_VALOR FROM " + RetSQLName("VDC") + " VDC"
cQuery += " INNER JOIN " + RetSQLName("VD9") + " VD9 ON"
cQuery += " VD9_FILIAL = '" + xFilial("VD9") + "' AND VD9_CODDEF = VDC_CODDEF AND VD9_CODCON = VDC_CODCON AND VD9.D_E_L_E_T_ = ' '"
cQuery += " WHERE VDC_FILIAL = '" + xFilial("VDC") + "'"
cQuery += " AND VDC_CODDEF = '" + MV_PAR02 + "' AND VDC_DATA = '" +dtos(MV_PAR03) + "' AND VDC.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY VD9.VD9_CONCTA"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias, .F., .T. )
//
nTotReg := Contar(cQryAlias, "!Eof()")
(cQryAlias)->(DBGoTop())
//
while !(cQryAlias)->(eof())
	
	if VAL((cQryAlias)->(VD9_CPODEF)) != 0
	
		cTipo := (cQryAlias)->(VD9_CONCTA)
		nPos := AT(".",cTipo)
		if nPos # 0
			cTipo := Left(cTipo,nPos - 1)
		endif
		
		DBSelectArea("VDA")
		DBSetOrder(1)
		DBSeek(xFilial("VDA")+MV_PAR02+(cQryAlias)->(VD9_CODCON))

		nValAcum := 0
		while !eof() .and. MV_PAR02 + (cQryAlias)->(VD9_CODCON)== VDA->VDA_CODDEF + VDA->VDA_CODCON
			if (Alltrim(VDA->VDA_CODEMP) == Alltrim(cEmpAnt) .and. Alltrim(VDA->VDA_CODFIL) == Alltrim(cFilAnt)) .or. Alltrim(cFilAnt) == Alltrim(VDA->VDA_ACUMEM)
				DBSelectArea("VDC")
				DBSetOrder(1)
				
				if DBSeek(Left(Alltrim(VDA->VDA_CODFIL)+space(20),TamSX3("VDC_FILIAL")[1])+MV_PAR02+dtos(MV_PAR03)+(cQryAlias)->(VD9_CODCON))
					nValAcum += VDC->VDC_VALOR
				endif
			endif
			DBSelectArea("VDA")
			DBSkip()
		enddo
		if !Empty(VDA->VDA_ACUMEM) .and. Alltrim(cFilAnt) != Alltrim(VDA->VDA_ACUMEM)
			nZeraAcu := 0
		else
			nZeraAcu := 1
		endif
	
		cLinha := STRZERO(YEAR(MV_PAR03),4) + ;
		STRZERO(MONTH(MV_PAR03),2) + ;
		STRZERO(VAL(cTipo),3) + ;
		STRZERO(VAL((cQryAlias)->(VD9_CPODEF)),6) + ;
		IIF(nValAcum < 0 .AND. nZeraAcu == 1 , "-","0") + ;
		STRZERO(ABS(nValAcum ) * 100 * nZeraAcu , 21)
	
		aAdd(aLinhasRel, STRZERO(YEAR(MV_PAR03),4) + " " + ;
		STRZERO(MONTH(MV_PAR03),2) + " " +;
		STRZERO(VAL((cQryAlias)->(VD9_CONCTA)),9) + " " +;
		IIF(nValAcum < 0, "-", "0") + " " +;
		STRZERO(ABS(nValAcum ) * 100 * nZeraAcu , 21) ) 
	
		fwrite(nHnd,cLinha + CHR(13) + CHR(10) )
	endif
	(cQryAlias)->(DBSkip())
enddo
fClose(nHnd)
//
(cQryAlias)->(dbCloseArea())
DBSelectArea("VDC")
//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    | ImprimeRel | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Imprime o resultado da exportação                            |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ImprimeRel()

Local nCntFor

Private cString  := "VV0"
Private Tamanho  := "M"
Private aReturn  := { "Zebrado",2,"Administracao",2,2,1,"",1 }
Private wnrel    := "OFINMT01"
Private NomeProg := "OFINMT01"
Private nLastKey := 0
Private Limite   := 132
Private Titulo   := cTitulo+" ("+cArquivo+")"+" - " + dtoc(ddatabase)
Private nTipo    := 0
Private cbCont   := 0
Private cbTxt    := " "
Private Li       := 80
Private m_pag    := 1
Private aOrd     := {}
Private Cabec1   := STR0009
Private Cabec2   := ""
Private cPerg := ""
//+-------------------------------------------------------------------------------
//| Solicita ao usuario a parametrizacao do relatorio.
//+-------------------------------------------------------------------------------
wnrel := SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,.F.,.F.)
//+-------------------------------------------------------------------------------
//| Se teclar ESC, sair
//+-------------------------------------------------------------------------------
If nLastKey == 27
	Return
Endif
//+-------------------------------------------------------------------------------
//| Estabelece os padroes para impressao, conforme escolha do usuario
//+-------------------------------------------------------------------------------
SetDefault(aReturn,cString)
//+-------------------------------------------------------------------------------
//| Verificar se sera reduzido ou normal
//+-------------------------------------------------------------------------------
nTipo := Iif(aReturn[4] == 1, 15, 18)
//+-------------------------------------------------------------------------------
//| Se teclar ESC, sair
//+-------------------------------------------------------------------------------
If nLastKey == 27
	Return
Endif
//+-------------------------------------------------------------------------------
//| Chama funcao que processa os dados
//+-------------------------------------------------------------------------------
for nCntFor = 1 to Len(aLinhasRel)

	If Li > 55
		li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		@li++, 0 psay " "
		li++
	Endif
	//
	@ Li++, 1   PSay aLinhasRel[nCntFor]
next
//
If Li <> 80
	Roda(cbCont,cbTxt,Tamanho)
Endif
//
If aReturn[5] == 1
	Set Printer TO
	dbCommitAll()
	OurSpool(wnrel)
EndIf
//
Ms_Flush()
//
return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | CriaSX1    | Autor |  Luis Delorme         | Data | 30/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function CriaSX1()
Local aSX1    := {}
Local aEstrut := {}
Local i       := 0
Local j       := 0
Local lSX1	  := .F.
Local nOpcGetFil := GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY

aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aAdd a Pergunta                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aAdd(aSX1,{cPerg,"01",STR0010,"","","MV_CH1","C",40,0,0,"G","!Vazio().or.(Mv_Par01:=cGetFile('Arquivos |*.*','',,,,"+AllTrim(Str(nOpcGetFil))+"))","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S"})
aAdd(aSX1,{cPerg,"02",STR0011,"","","MV_CH2","C",6,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","VD7",""	,"S"})
aAdd(aSX1,{cPerg,"03",STR0012,"","","MV_CH3","D",8,0,0,"G","ONMT01VP()","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S"})

ProcRegua(Len(aSX1))

dbSelectArea("SX1")
dbSetOrder(1)
For i:= 1 To Len(aSX1)
	If !Empty(aSX1[i][1])
		If !dbSeek(Left(Alltrim(aSX1[i,1])+SPACE(100),Len(SX1->X1_GRUPO))+aSX1[i,2])
			lSX1 := .T.
			RecLock("SX1",.T.)

			For j:=1 To Len(aSX1[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
				EndIf
			Next j

			dbCommit()
			MsUnLock()
		EndIf
	EndIf
Next i

return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX052VP    | Autor |  Luis Delorme         | Data | 30/04/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Validacao da Pergunte                                        |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function ONMT01VP()

if Month(MV_PAR03) == Month(MV_PAR03+1)
	MsgStop(STR0013)
	return .f.
endif

return .t.