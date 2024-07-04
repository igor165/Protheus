#Include "fileio.ch"
#Include "Protheus.ch"
#Include "GPEM700.CH"
#define CRLF Chr(13)+Chr(10)                       

/*                                                                           
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RSPM004  ºAutor  ³Oswaldo L                       ³  05/10/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                  ³±±
±±ÌÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	  ³ BOPS/FNC  ³  Motivo da Alteracao 		           ³±±
±±ÌÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºOswaldo L  |30/10/17|DRHPAG-7555|Carga inicial dos dados do RHLAYOUT.DTC    ³±±
±±³           |        |           |para tabela fisica do projeto Ctree(SGX)   ³±±
±±³           |        |           |Manter tratativas ctree neste fonte        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function RSPM004()
Local aArea			
Local cPath		:= ""
Local cPath1	:= ""
Local cPath2	:= ""
Local cArqBkp	:= ""
Local cArquivo	:= "RHLAYOUT"
Local cArqDbf	:= cArquivo+GetDBExtension()
Local cArqNtx	:= cArquivo+OrdBagExt()
Local cIndCond	:= "TRB_BANCO+TRB_LAYOUT"
Local cDriver	:= "DBF"
Local aFields	:= {}
Local cRDD		:= __LocalDriver

//==============
Local aSays    := {}
Local aButtons := {}
Local lOk      := .F. 
Local aPergs := {}  

Private cArqDados := ""

//==============
Private aSize := {}
Private aInfo := {}
Private aObj := {}
Private aPObj := {}
Private aPGet := {} // Retorna a area util das janelas Protheus 

aSize := MsAdvSize() // Sera utilizado tres areas na janela 
		// 1ª - Enchoice, sendo 80 pontos pixel 
		// 2ª - MsGetDados, o que sobrar em pontos pixel e para este objeto 
		// 3ª - Rodape que e a propria janela, sendo 15 pontos pixel 
AADD( aObj, { 100, 100, .T., .T. }) 
	
// Cálculo automático da dimensões dos objetos (altura/largura) em pixel 
aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 } 
aPObj := MsObjSize( aInfo, aObj ) 

// Cálculo automático de dimensões dos objetos MSGET 
aPGet := MsObjGetPos( (aSize[3] - aSize[1]), 315, { {004, 024, 240, 270} } )         

AAdd(aSays, OemtoAnsi(STR0166))//'Devido a otimização das rotinas de Consignação, foi criada nova tabela no sistema')
AAdd(aSays, OemtoAnsi(STR0167))//'(tabela SGX). Esta rotina efetua a carga desta com as informações que se encontram')
AAdd(aSays, OemtoAnsi(STR0168))//'armazenadas em arquivos (RHLAYOUT) no diretório SYSTEM do sistema.')
			
AAdd(aButtons,{01, .T., {|o| lOk := .T., FechaBatch()}})
AAdd(aButtons,{02, .T., {|o| lOk := .F., FechaBatch()}})
		
FormBatch(OemtoAnsi(STR0169), aSays, aButtons)    

If lOk

	AADD( aFields , { 'TRB_BANCO' , 'C',  03, 0 } )
	AADD( aFields , { 'TRB_NOME'  , 'C',  20, 0 } )
	AADD( aFields , { 'TRB_LAYOUT', 'C',  01, 0 } )
	AADD( aFields , { 'TRB_CONFIG', 'C', 150, 0 } )
	AADD( aFields , { 'TRB_POSCPF', 'C',  03, 0 } ) // Posicao CPF
	AADD( aFields , { 'TRB_POSPAR', 'C',  03, 0 } ) // Posicao Parcela
	AADD( aFields , { 'TRB_POSVAL', 'C',  03, 0 } ) // Posicao Valor da Parcela
	AADD( aFields , { 'TRB_VERBA' , 'C',  03, 0 } ) // Verba para desconto em folha
	AADD( aFields , { 'TRB_VERRES', 'C',  03, 0 } ) // Verba para desconto em rescisao
	AADD( aFields , { 'TRB_REMRET', 'C',  03, 0 } ) // Remessa/Retorno
	AADD( aFields , { 'TRB_TIPOPG', 'C',  03, 0 } ) // Tipo de Pagamento (Averbacao, Manutencao, Consignacao)
	AADD( aFields , { 'TRB_QTCON' , 'C',  03, 0 } ) // Posicao Qtde Total Consignado (Parcelas)
	AADD( aFields , { 'TRB_QTNCON', 'C',  03, 0 } ) // Posicao Qtde Total Nao Consignado (Parcelas)
	AADD( aFields , { 'TRB_VLCON' , 'C',  03, 0 } ) // Posicao Valor Total Consignado
	AADD( aFields , { 'TRB_VLNCON', 'C',  03, 0 } ) // Posicao Valor Total Nao Consignado
	
	If File(cArqDbf)
		// Monta o path do arquivo de acordo com Mp8Srv.ini
		cPath1 := GetPvProfString( GetEnvServer(),"RootPath","",GetAdv97() )
		cPath2 := GetPvProfString( GetEnvServer(),"StartPath","",GetAdv97() )
		cPath  := cPath1 + cPath2
		
		nPos  := At("\\",cPath)
		If nPos > 0
			cPath := SubStr(cPath,1,nPos-1) + SubStr(cPath,nPos+1)
		Endif
		If Right(cPath,1) != "\"
			cPath += "\"
		Endif
	
		MsOpenDbf(.T., cRDD,cArqDbf,"TRB", .T., .F.)
	
		If TRB->( Type("TRB_VERRES") ) == "U" .OR. ;
		   TRB->( Type("TRB_REMRET") ) == "U" .OR. ;
		   TRB->( Type("TRB_TIPOPG") ) == "U" .OR. ;
		   TRB->( Type("TRB_QTCON" ) ) == "U" .OR. ;
		   TRB->( Type("TRB_QTNCON") ) == "U" .OR. ;
		   TRB->( Type("TRB_VLCON" ) ) == "U" .OR. ;
		   TRB->( Type("TRB_VLNCON") ) == "U"
			TRB->( DbCloseArea() )
			
			cArqBkp := RetArq(cDriver,cArquivo+".#DB",.F.)
	
			FErase(cArqBkp)
			FRename(cPath+cArqDbf,cPath+cArqBkp)
			FErase(cArqNtx)
				
			// Cria o novo arquivo
			DbCreate(cArqDbf,aFields,cRDD)
				
			// Abre o novo arquivo e faz append do backup
			MsOpenDbf(.T.,cRDD,cArqDbf,"TRB",.T.,.F.)
			DbSelectArea("TRB")
			MyAppend("TRB",cArqBkp)
		Endif
		
		Set Index To (cArqNtx)
	
		FWMsgRun(,{|| Importar()   },OemtoAnsi(STR0076),OemtoAnsi(STR0059))
								
	Endif
	
	If Select("TRB") > 0 
		TRB->( DbCloseArea() )
	EndIf

EndIf


Return


/*                                                                           
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Importar ºAutor  ³Oswaldo L                       ³  05/10/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                  ³±±
±±ÌÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	  ³ BOPS/FNC  ³  Motivo da Alteracao 		           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Importar ()
Local cSql := "DELETE FROM " + RetSqlname("SGX")//ao executar diversas vezes a rotina,sempre recriar

TCSQLEXEC(cSql)

TRB->(DbGoTop())
	
While (TRB->(!Eof()))

	reclock('SGX',.T.)
	SGX->GX_FILIAL := Fwxfilial('SGX')
	SGX->GX_BCO   := TRB->TRB_BANCO
	SGX->GX_NOME  := TRB->TRB_NOME	
	SGX->GX_LAYO  := TRB->TRB_LAYOUT
	SGX->GX_CONF  := TRB->TRB_CONFIG
	SGX->GX_POSC  := TRB->TRB_POSCPF
	SGX->GX_POSP  := TRB->TRB_POSPAR
	SGX->GX_POSV  := TRB->TRB_POSVAL
	SGX->GX_REMR  := TRB->TRB_REMRET
	SGX->GX_TIPOP := TRB->TRB_TIPOPG
	SGX->GX_VERBA := TRB->TRB_VERBA
	SGX->GX_VERRE := TRB->TRB_VERRES
	SGX->GX_QTCON := TRB->TRB_QTCON
	SGX->GX_QTNC  := TRB->TRB_QTNCON
	SGX->GX_VLCON := TRB->TRB_VLCON
	SGX->GX_VLNC  := TRB->TRB_VLNCON
	MsUnLock()
		
	TRB->(DbSkip())
End

return