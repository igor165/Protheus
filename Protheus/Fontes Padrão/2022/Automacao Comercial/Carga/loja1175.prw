#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1175.CH"

// O protheus necessita ter ao menos uma fun็ใo p๚blica para que o fonte seja exibido na inspe็ใo de fontes do RPO.
Function LOJA1175() ; Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} LJCInitialLoadDeleteLoad()

Classe para controlar a exclusao das cargas 

Utilize o metodo Start para deletar uma carga na retaguarda. 
Utilize o metodo CleanClientTrash para apagar todo o lixo dos clientes (cargas que ja foram excluidas na retaguarda)

@author Vendas CRM
@since 07/08/12
/*/
//--------------------------------------------------------------------------------  
Class LJCInitialLoadDeleteLoad From FWSerialize
	Data oLoadGroups
	Data aSelection
	Data nExtFile

	Method New()	
	Method Start() //Inicia o processo para deletar as cargas selecionadas no aSelection (Limpar carga na retaguarda)
	Method CleanClientTrash() //Limpa arquivos de cargas nao existentes (utilizado para limpar os ambientes filhos)
	
	
	Method ProcessAllIncrementalLoad() //MSEXP - percorre as cargas incrementais marcando as cargas sequenciais para excluir
	Method DeleteIncLoad()//MSEXP - deleta uma carga incremental
	Method ProcessLoadMSEXP() 
	Method ProcessParcialTableMSEXP() //retorna o MSEXP de uma tabela de carga parcial
	Method ProcessTableMSEXP() //retorna o MSEXP de uma tabela de carga completa 
	Method ProcessSpecialTableMSEXP()//retorna o MSEXP da SB0 e SB1 baseado na SBI
	Method Decompress()
	Method DeleteSimpleLoad() //apaga a carga da MBU e apaga os arquivos fisicos
	Method RemoveDir() //apaga os arquivos e remove o diretorio
		 
	
	
EndClass


//--------------------------------------------------------------------------------
/*/{Protheus.doc} New()

Construtor

@param oLoadGroups lista de cargas. 
@param aSelection selecao das cargas. 

@return Self

@author Vendas CRM
@since 07/08/12
/*/
//--------------------------------------------------------------------------------  
Method New(oLoadGroups, aSelection) Class LJCInitialLoadDeleteLoad
	Self:oLoadGroups 	:= oLoadGroups
	Self:aSelection 	:= aSelection
	Self:nExtFile		:= SuperGetMV("MV_LJTFILE",.F.,0)
Return




//--------------------------------------------------------------------------------
/*/{Protheus.doc} Start()

Inicia a exclusao das cargas selecionadas em aSelection

@param lRestMSEXP determina se restaura o MSEXP 
@param aSelection selecao das cargas. 

@return Self

@author Vendas CRM
@since 07/08/12
/*/
//--------------------------------------------------------------------------------  
Method Start(lRestMSEXP) Class LJCInitialLoadDeleteLoad
Local cMinOrder 			:= ""		//campo auxiliar para guardar a menor ordem da carga incremental a ser excluida
Local nI					:= 0
Local lUpdateOrderLoad		:= .F.	//determina se deve voltar a contagem da ordem das cargas (verdadeiro quando for restaurar o msexp). Deve ser usado quando a delecao for por ter criado errado uma carga e ignorado completamente sua existencia.

//Processa todas as cargas inteiras primeiro
For nI := 1 to Len(Self:oLoadGroups:aoGroups)
	If Self:oLoadGroups:aoGroups[nI]:cEntireIncremental == "1" .AND. Self:aSelection[nI]
		Self:DeleteSimpleLoad(Self:oLoadGroups:aoGroups[nI]) //apaga itens basicos de uma carga (sem restaurar o MSEXP)
	EndIf
Next nI


If lRestMSEXP // .T. = restaura MSEXP | .F. = nao mexe no MSEXP, apenas exclui da MBU e exclui os arquivos fisicos 
	//Processa as cargas incrementais - aqui ira alterar a selecao do aSelection 
	//primeiro faz uma busca da carga incremental mais antiga e marca no aSelection para apagar todas as cargas incrementais posteriores
	For nI := 1 to Len(Self:oLoadGroups:aoGroups)
		If Self:oLoadGroups:aoGroups[nI]:cEntireIncremental == "2" 
			If Empty(cMinOrder) .AND. Self:aSelection[nI] //se ainda nao encontrou a primeira incremental marcada pra exclusao
				cMinOrder := Self:oLoadGroups:aoGroups[nI]:cOrder
			ElseIf !Empty(cMinOrder) //se ja encontrou a incremental mais antiga marca para apagar todas abaixo dela
				Self:aSelection[nI] := .T.
			EndIf
		EndIf
	Next nI
	
	If !Empty(cMinOrder) 
		lUpdateOrderLoad := .T.
		Self:ProcessAllIncrementalLoad()
	EndIf
	
Else
//Processa todas as cargas incrementais sem mexer no MSEXP
	For nI := 1 to Len(Self:oLoadGroups:aoGroups)
		If Self:oLoadGroups:aoGroups[nI]:cEntireIncremental == "2" .AND. Self:aSelection[nI]
			Self:DeleteSimpleLoad(Self:oLoadGroups:aoGroups[nI]) //apaga itens basicos de uma carga (sem restaurar o MSEXP)
		EndIf
	Next nI

EndIf

//gera novamente o xml com as cargas disponiveis
LJ1156XMLResult(lUpdateOrderLoad)

Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} ProcessAllIncrementalLoad()

Processa as cargas incrementais

@author Vendas CRM
@since 07/08/12
/*/
//--------------------------------------------------------------------------------  
Method ProcessAllIncrementalLoad() Class LJCInitialLoadDeleteLoad
Local nI	:= 0
	
//percorre a lista do final para o comeco, para restaurar o MSEXP da carga mais recente ate a mais antiga e garantir o estado correto dos dados
For nI := Len(Self:oLoadGroups:aoGroups) to 1 Step -1
	If Self:oLoadGroups:aoGroups[nI]:cEntireIncremental == "2" .AND. Self:aSelection[nI] 
		Self:DeleteIncLoad(Self:oLoadGroups:aoGroups[nI])	//restaura o MSEXP da carga
		Self:DeleteSimpleLoad(Self:oLoadGroups:aoGroups[nI])//apaga itens basicos de uma carga (sem restaurar o MSEXP)
	EndIf
Next nI
	
Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} DeleteIncLoad()

Realiza todo o processo para excluir uma carga incremental restauraurando o MSEXP de uma carga especifica (recebida por parametro)

@param oGroup grupo de carga

@author Vendas CRM
@since 07/08/12
/*/
//-------------------------------------------------------------------------------- 
Method DeleteIncLoad(oGroup) Class LJCInitialLoadDeleteLoad
Local nCount 	:= 0
Local oLJCMessageManager	:= GetLJCMessageManager()
Local oLJILFileServerConfiguration	:= LJCFileServerConfiguration():New()	
Local cPath

cPath := oLJILFileServerConfiguration:GetPath() + oGroup:cCode + If( IsSrvUnix(), "/", "\" )

// Descompacta os arquivos
For nCount := 1 To Len( oGroup:oTransferFiles:aoFiles )
	Self:Decompress( oGroup:oTransferFiles:aoFiles[nCount]:GetFile(), cPath  )
	If oLJCMessageManager:HasError()
		Exit
	EndIf
Next

//restaura MSEXP das tabelas existentes na carga
Self:ProcessLoadMSEXP(oGroup, cPath )


Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} ProcessTableMSEXP()

faz o processamento para restaurar o MSEXP da tabela do tipo completa

@param oTable tabela
@param cPath caminho do arquivo fisico
@param oGroup grupo de carga


@author Vendas CRM
@since 07/08/12
/*/
//--------------------------------------------------------------------------------
Method ProcessTableMSEXP( oTable, cPath, oGroup ) Class LJCInitialLoadDeleteLoad
Local nCount 						:= 0
Local cFileName					:= ""
Local cIndexKey					:= ""

DbSelectArea(oTable:cTable)
For nCount := 1 To Len( oTable:aBranches )
	If Empty( xFilial( oTable:cTable ) ) .Or. Empty( oTable:aBranches[nCount] ) .Or. xFilial( oTable:cTable ) == oTable:aBranches[nCount]
		cFileName := cPath  + oTable:cTable + cEmpAnt + AllTrim(oTable:aBranches[nCount]) + oGroup:cExtension
		If File(cFileName)
			// Abre a area com o arquivo novo
			DbUseArea(.T., oGroup:cDriver, cFileName, "TRB", .F., .F.)
			If Used()
		
				TRB->(DbGoTop())
				While TRB->(!EOF())
				
					DbSelectArea( oTable:cTable )
					DbSetOrder( 1 )
					cIndexKey := ( oTable:cTable ) -> (IndexKey(1)) 
					
					If ( oTable:cTable )->( DbSeek( TRB->(&cIndexKey) ) ) //procura se o registro ja existe
						RecLock(  oTable:cTable , .F. ) //da um reclock soh para limpar o MSEXP, dessa forma o registro sera exportado novamente
						(oTable:cTable)->(MsUnLock())
					EndIf
				
				TRB->(DbSkip())
				EndDo
			
				// Fecha o arquivo de trabalho 
				TRB->(DBCloseArea())
			
			
			EndIf
		EndIf
	EndIf	

Next nCount


Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} ProcessParcialTableMSEXP()

faz o processamento para restaurar o MSEXP da tabela do tipo completa

@param oTable tabela
@param cPath caminho do arquivo fisico
@param oGroup grupo de carga


@author Vendas CRM
@since 07/08/12
/*/
//--------------------------------------------------------------------------------
Method ProcessParcialTableMSEXP( oTable, cPath, oGroup ) Class LJCInitialLoadDeleteLoad
Local nCount 						:= 0
Local cFileName					:= ""
Local cIndexKey					:= ""
Local oTransfFile					:= LJCInitialLoadMakerTransferFile():New( oTable:cTable, cEmpAnt, "" )


cFileName := cPath  + oTransfFile:GetFileWithoutExtension() + oGroup:cExtension
If File(cFileName)
	// Abre a area com o arquivo novo
	DbUseArea(.T., oGroup:cDriver, cFileName, "TRB", .F., .F.)
	If Used()

		TRB->(DbGoTop())
		While TRB->(!EOF())
		
			DbSelectArea( oTable:cTable )
			DbSetOrder( 1 )
			cIndexKey := ( oTable:cTable ) -> (IndexKey(1)) 
			
			If ( oTable:cTable )->( DbSeek( TRB->(&cIndexKey) ) ) //procura se o registro ja existe
				RecLock(  oTable:cTable , .F. ) //da um reclock soh para limpar o MSEXP, dessa forma o registro sera exportado novamente
				(oTable:cTable)->(MsUnLock())
			EndIf
		
		TRB->(DbSkip())
		EndDo
	
		// Fecha o arquivo de trabalho 
		TRB->(DBCloseArea())
	
	
	EndIf
EndIf

Return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} ProcessSpecialTableMSEXP()

faz o processamento para restaurar o MSEXP da tabela especial

@param oTable tabela
@param cPath caminho do arquivo fisico
@param oGroup grupo de carga


@author Vendas CRM
@since 07/08/12
/*/
//--------------------------------------------------------------------------------
Method ProcessSpecialTableMSEXP( oTable, cPath, oGroup ) Class LJCInitialLoadDeleteLoad
Local nCount 						:= 0
Local cFileName					:= ""
Local cIndexKey					:= ""


/*
avalia a tabela exportada (SBI) e retorna o MSEXP dos registros da SB1 correspondentes
Obs: nao retorna a SB0 pq basta retornarr a SB1 pra exportar novamente.
Obs2: o modo de compartilhamento da SB1 eh o mesmo da SBI, conforme as combinacoes abaixo

	1 -
		SB1 - Compartilhado
		SBI - Compartilhado
		SB0 - Compartilhado
	2 -
		SB1 - Compartilhado
		SBI - Compartilhado
		SB0 - Exclusivo
	3 -
		SB1 - Exclusivo
		SBI - Exclusivo
		SB0 - Exclusivo
	 
*/

For nCount := 1 To Len( oTable:aParams[1] )
	If Empty( xFilial( oTable:cTable ) ) .Or. Empty( oTable:aParams[1][nCount] ) .Or. xFilial( oTable:cTable ) == oTable:aParams[1][nCount]
		cFileName := cPath  + oTable:cTable + cEmpAnt + AllTrim(oTable:aParams[1][nCount]) + oGroup:cExtension
		If File(cFileName)
			// Abre a area com o arquivo novo
			DbUseArea(.T., oGroup:cDriver, cFileName, "TRB", .F., .F.)
			If Used()
		
				TRB->(DbGoTop())
				While TRB->(!EOF())
				
					DbSelectArea( "SB1" )
					DbSetOrder( 1 )
					
					If DbSeek(xFilial("SB1") + TRB->BI_COD  ) //procura se o registro ja existe
						RecLock(  "SB1", .F. ) //da um reclock soh para limpar o MSEXP, dessa forma o registro sera exportado novamente
						SB1->(MsUnLock())
					EndIf
				
				TRB->(DbSkip())
				EndDo
			
				// Fecha o arquivo de trabalho 
				TRB->(DBCloseArea())
			
			
			EndIf
		EndIf
	EndIf	

Next nCount

Return



//--------------------------------------------------------------------------------
/*/{Protheus.doc} ProcessLoadMSEXP()

faz o processamento para restaurar o MSEXP (verifica o tipo da tabela e utiliza
o metodo apropriado)

@param cPath caminho do arquivo fisico
@param oGroup grupo de carga


@author Vendas CRM
@since 07/08/12
/*/
//--------------------------------------------------------------------------------
Method ProcessLoadMSEXP(oGroup, cPath) Class LJCInitialLoadDeleteLoad

Local nCount := 0

For nCount := 1 To Len( oGroup:oTransferTables:aoTables )
	If Lower(GetClassName( oGroup:oTransferTables:aoTables[nCount] )) == Lower("LJCInitialLoadSpecialTable")
		Self:ProcessSpecialTableMSEXP( oGroup:oTransferTables:aoTables[nCount], cPath , oGroup ) //SBI -> retorna MSEXP da SB0 e SB1
	ElseIf Lower(GetClassName( oGroup:oTransferTables:aoTables[nCount] )) == Lower("LJCInitialLoadCompleteTable")
		Self:ProcessTableMSEXP( oGroup:oTransferTables:aoTables[nCount], cPath , oGroup )
	ElseIf Lower(GetClassName( oGroup:oTransferTables:aoTables[nCount] )) == Lower("LJCInitialLoadPartialTable")
		If !(oGroup:oTransferTables:aoTables[nCount]:cTable $ "SX5,SX6")  //SX5 e SX6 nao restaura MSEXP 
		Self:ProcessParcialTableMSEXP( oGroup:oTransferTables:aoTables[nCount], cPath , oGroup )	
		EndIf
	EndIf
Next nCount



Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัอออออออออออออออออออออออออออออออออออัอออออออออออออออออออัออออออออออออออออปฑฑ
ฑฑบ     M้todo: ณ Decompress                        ณ Autor: Vendas CRM ณ Data: 07/02/10 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออฯอออออออออออออออออออฯออออออออออออออออนฑฑ
ฑฑบ  Descri็ใo: ณ Descompacta o arquivo desejado.                                        บฑฑ
ฑฑบ             ณ                                                                        บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros: ณ cFile: Nome do arquivo a ser descompactado.                            บฑฑ
ฑฑบ 			  ณ cPath: caminho do arquivo a ser descompactado.                            บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ    Retorno: ณ Nil                                                                    บฑฑ
ฑฑศอออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Decompress( cFile, cPath ) Class LJCInitialLoadDeleteLoad
	Local oLJCMessageManager	:= GetLJCMessageManager()
		
	If IIF(Self:nExtFile == 0, !MsDecomp( cPath + cFile, cPath ), FUnzip(cPath + cFile, "\") <> 0)
		oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadLoaderDecompressError", 1, STR0001 + " '" + cPath + cFile  + "'" ) ) // "Nใo foi possํvel descompactar o arquivo:"
	EndIf
Return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} DeleteSimpleLoad()

Exclui uma carga sem restaurar o MSEXP

@param oGroup grupo de carga
@param cPath caminho do arquivo fisico


@author Vendas CRM
@since 07/08/12
/*/
//--------------------------------------------------------------------------------
Method DeleteSimpleLoad(oGroup, cPath) Class LJCInitialLoadDeleteLoad

Local oLJCMessageManager			:= GetLJCMessageManager()
Local oLJILFileServerConfiguration	:= LJCFileServerConfiguration():New()	
Local cPath	:= ""


cPath := oLJILFileServerConfiguration:GetPath() + oGroup:cCode + If( IsSrvUnix(), "/", "\" )

//Apaga MBU
DbSelectArea( "MBU" )
DbSetOrder(1)
If DbSeek(xFilial("MBU") + oGroup:cCode)
	If RecLock( "MBU", .F. )
		MBU->( DbDelete() )
		MBU->( MsUnLock() )

		DbSelectArea( "MBV" )//MBV_FILIAL+MBV_CODGRP+MBV_TABELA
		DbSetOrder( 1 )
		If MBV->( DbSeek( xFilial( "MBV" ) + MBU->MBU_CODIGO ) )
			While	MBV->MBV_FILIAL + MBV->MBV_CODGRP ==  xFilial( "MBV" ) + MBU->MBU_CODIGO .And.;
					MBV->( !EOF() )
				RecLock( "MBV", .F. )
				MBV->( DbDelete() )
				MBV->( MsUnLock() )
				MBV->( DbSkip() )				
			End
		EndIf

		DbSelectArea( "MBX" )//MBX_FILIAL+MBX_CODGRP+MBX_TABELA+MBX_FIL
		DbSetOrder( 1 )
		If MBX->( DbSeek( xFilial( "MBX" ) + MBU->MBU_CODIGO ) )
			While	MBX->MBX_FILIAL + MBX->MBX_CODGRP ==  xFilial( "MBX" ) + MBU->MBU_CODIGO .And.;
					MBX->( !EOF() )
				RecLock( "MBX", .F. )
				MBX->( DbDelete() )
				MBX->( MsUnLock() )
				MBX->( DbSkip() )				
			End
		EndIf
		
	EndIf						
EndIf

Self:RemoveDir(cPath)

Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} RemoveDir()

remove o diretorio

@param cPath caminho do arquivo fisico


@author Vendas CRM
@since 07/08/12
/*/
//--------------------------------------------------------------------------------
Method RemoveDir(cPath) Class LJCInitialLoadDeleteLoad
Local nI 		:= 0
Local aDirectory 	:= {}

//Apaga o diretorio fisico
aDirectory := Directory(cPath + "*.*" , "D")
For nI := 1 To Len( aDirectory )
	If aDirectory[nI][1] <> '.' .AND. aDirectory[nI][1] <> '..'
		If aDirectory[nI][5] == "A" // Se for um arquivo
			FErase( cPath + aDirectory[nI][1] ) 
		Elseif	aDirectory[nI][5] == "D" // apaga subdiretorios do Ctree
			DirRemove(cPath + aDirectory[nI][1] + If( IsSrvUnix(), "/", "\" )) // Apaga diret๓rio 
		Endif
	EndIf	
	
Next			
									
DirRemove(cPath)


Return



//--------------------------------------------------------------------------------
/*/{Protheus.doc} CleanClientTrash()

remove os diretorios das cargas ja excluidas no servidor (retaguarda)


@author Vendas CRM
@since 07/08/12
/*/
//--------------------------------------------------------------------------------
Method CleanClientTrash() Class LJCInitialLoadDeleteLoad

Local cIP						:= SuperGetMV("MV_LJILLIP", .F.)
Local cPort						:= SuperGetMV("MV_LJILLPO", .F.)
Local cEnv						:= SuperGetMV("MV_LJILLEN", .F.)
Local cCompany					:= SuperGetMV("MV_LJILLCO", .F.)
Local cBranch						:= SuperGetMV("MV_LJILLBR", .F.)
Local oFather 					:= LJCInitialLoadClient():New(cIP, Val(cPort), cEnv, cCompany, cBranch )
Local oLJFatherMessenger			:= LJCInitialLoadMessenger():New( oFather )
Local nQtyLoadFather 				:= 0		// limite de cargas da retaguarda definida no parametro MV_LJILQTD
Local nTotCount					:= 0		// quantidade de registros na tabela de status
Local nTotLoadRet					:= 0		// quantidade de cargas na lista total enviada por xml
Local oLJILFileServerConfiguration	:= LJCFileServerConfiguration():New(.F.)	
Local cPath 						:= oLJILFileServerConfiguration:GetPath()
Local cNameFolder					:= ""
Local lFound						:= .F.
Local nI							:= 0

If Self:oLoadGroups <> Nil 
	nTotLoadRet := Len(Self:oLoadGroups:aoGroups)
EndIf

nQtyLoadFather := oLJFatherMessenger:GetMVQtyMax()


//Protecao contra falha no processo de pegar o valor do pai
If ValType(nQtyLoadFather) == 'N' .AND. nQtyLoadFather > 0
		
	//Mantem o parametro localmente atualizado para casos onde o PDV tem filhos que irao consulta-lo
	PutMV("MV_LJILQTD", nQtyLoadFather)
			
	DBSelectArea("MBY")
	DbSetOrder(1)// filial + codCarga
	If DbSeek( xFilial("MBY") )
		While MBY_FILIAL == xFilial("MBY") .AND. MBY->(!Eof())
			nTotCount++
			MBY->(DbSkip())
		EndDo
	EndIf
	
	
	//--------------------------------------------------------------------------------------------------------------------
	//Verifica se o total de status eh maior que a lista de cargas e que 2x o limite do parametro
	//Define um limite de status maior que o limite de lista do parametro (2x) por seguran็a.
	//Nao hแ problema em garantir o dobro da qtde pq o xml de lista estoura 1 MB muito 
	//mais rapido que o de status. A proporcao eh muito maior que 2x.   
	//Obs: precisa verificar as duas coisas (limite e qtde na lista), o pq a lista pode ser maior que o parametro 
	//(quando alteram o parametro s๓ verifica a qtde da lista na geracao de uma nova carga)
	//--------------------------------------------------------------------------------------------------------------------
	If (nTotLoadRet > 0) .AND. (nTotCount > (2*nQtyLoadFather) ) .AND. (nTotCount > nTotLoadRet)
		DBSelectArea("MBY")
		DbSetOrder(1)// filial + codCarga - nao da dbsetorder pra ordenar pelo recno
		If DbSeek( xFilial("MBY") )
			//Apaga enquanto tiver mais carga no status do que a qtde do parametro ou da lista (para quando chegar em alguma das duas qtde. O que chegar primeiro)
			While ((2*nQtyLoadFather) < nTotCount ) .AND. (nTotLoadRet < nTotCount )
				
				//faz uma busca pela carga a ser apagada como prote็ใo para nao apagar cargas que existam na lista
				For nI := 1 to Len(Self:oLoadGroups:aoGroups)
					If Self:oLoadGroups:aoGroups[nI]:cCode == MBY->MBY_CODGRP
						lFound := .T.
						Exit
					EndIf
				Next nI
				
				If !lFound .AND. RecLock( "MBY", .F. )
					cNameFolder := MBY->MBY_CODGRP
					MBY->( DbDelete() )
					MBY->( MsUnLock() )
				Self:RemoveDir(cPath + cNameFolder + If(IsSrvUnix(),"/","\" ) ) //soh remove a pasta se conseguir apagar o registro
				EndIf		
				nTotCount--
				MBY->(DbSkip())
			EndDo
		EndIf		
	EndIf
			
EndIf

	

Return
