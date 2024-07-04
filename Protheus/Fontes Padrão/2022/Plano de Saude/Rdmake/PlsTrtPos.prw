
#INCLUDE "PROTHEUS.CH"

User Function PlsTrtPos()
Local aCab := {}
Local aIte := {}
Local aRet
Local nI
Local nPos
Local cCodPro
Local cCodInt
Local cUsuario
Local dData
Local cData

/*
   aCab
		OPEMOV		- Operadora responsavel pelo movimento
		USUARIO		- Matricula do usuario
		DATPRO		- Data do procedimento
		HORAPRO		- Hora do procedimento
		CIDPRI		- Cid principal
		CODRDA		- Codigo da Rede de Atendimento

	aItens

		SEQMOV		- Sequencia do item
		CODPAD		- Codigo tipo tabela padrao (geralmente "01")
		CODPRO		- Codigo do Procedimento
		QTD			- Qtd do procedimento


	Matriz na seguinte estrutura

		[1] - Autorizada (.T.) ou nao (.F.)
		[2] - Numero da autorizacao (se for autorizada)
		[3] - Senha da autorizacao (se for autorizada)
		[4] - Criticas (se nao foi autorizada)

		       [4] na seguinte estrutura

			4,x,1 -> Sequencia do item (SEQMOV)
			4,x,2 -> Codigo da critica
			4,x,3 -> Descricao da critica
			4,x,4 -> Informacao da critica

*/

If PlsPOSGet("CODTRANS",aDados) == "0700" // Pedido de consulta
   cCodInt := SubStr(PlsPOSGet("TRILHACAR",aDados),1,4)
   cCodUsu := SubStr(PlsPOSGet("TRILHACAR",aDados),1,17)
   cData := PlsPOSGet("DATA",aDados)
   dData := CtoD(SubStr(cData,1,2)+"/"+SubStr(cData,3,2)+"/"+SubStr(cData,5,4))
   aadd(aCab,{"OPEMOV",cCodInt})
   aadd(aCab,{"USUARIO",cCodUsu})
   aadd(aCab,{"DATPRO",dData })
   aadd(aCab,{"HORAPRO",PlsPOSGet("HORAPRO",aDados)})
   aadd(aCab,{"CIDPRI",NIL })
   aadd(aCab,{"CODRDA",NIL })
   cCodPro := GetNewPar("MV_PLSCDCO",'')
   aadd(aIte,{"SEQMOV",01 })
   aadd(aIte,{"CODPAD",SubStr(cCodPro,1,2)  })
   aadd(aIte,{"CODPRO",SubStr(cCodPro,3)  })
   aadd(aIte,{"QTD",1 })
   aRet := PLSXAUTP(aCab,aIte)
   If aRet[1]   // autorizou
      conout("*** AUTORIZADO ***")
      PlsPosPut("CODRES","00",aDados)
      PlsPosPut("FLAGCONS","N",aDados)
      PlsPosPut("NUMDOC",aRet[2],aDados)   // NUMERO DA AUTORIZACAO
   Else  // nao autorizou
      conout("*** NAO AUTORIZADO ***")
      PlsPosPut("NUMDOC","000000000",aDados)   // NUMERO DA AUTORIZACAO
      PlsPosPut("CODRES",MsgErro(aRet[4,1,2]),aDados)
   EndIf
ElseIf PlsPOSGet("CODTRANS",aDados) == "0701" // Pedido de autorizacao de exames
   cCodInt := SubStr(PlsPOSGet("TRILHACAR",aDados),1,4)
   cCodUsu := SubStr(PlsPOSGet("TRILHACAR",aDados),1,17)
   cData := PlsPOSGet("DATA",aDados)
   dData := CtoD(SubStr(cData,1,2)+"/"+SubStr(cData,3,2)+"/"+SubStr(cData,5,4))
   aadd(aCab,{"OPEMOV",cCodInt})
   aadd(aCab,{"USUARIO",cCodUsu})
   aadd(aCab,{"DATPRO",dData })
   aadd(aCab,{"HORAPRO",PlsPOSGet("HORAPRO",aDados)})
   aadd(aCab,{"CIDPRI",NIL })
   aadd(aCab,{"CODRDA",NIL })
   For nI := 1 to Len(aItens)
      cCodPro := PlsPOSGet("CODSERV",aItens[nI])
      aadd(aIte,{"SEQMOV",nI })
      aadd(aIte,{"CODPAD",SubStr(cCodPro,1,2)  })
      aadd(aIte,{"CODPRO",SubStr(cCodPro,3)  })
      aadd(aIte,{"QTD",Val(PlsPOSGet("QTDSOL",aItens[nI])) })
      PlsPosPut("CODAUT","00",aItens[nI])
   Next
   aRet := PLSXAUTP(aCab,aIte)
   For nI := 1 to Len(aRet[4])
      nPos     := Val(aRet[4,nI,1])
      cCodErro := MsgErro(aRet[4,nI,2])
      PlsPosPut("CODAUT",cCodErro,aItens[nPos])
   Next
   If aRet[1]   // autorizou
      conout("*** AUTORIZADO EXAME ***")
      PlsPosPut("CODRES","00",aDados)
      PlsPosPut("FLAGCONS","N",aDados)
      PlsPosPut("NUMDOC",aRet[2],aDados)   // NUMERO DA AUTORIZACAO
   Else  // nao autorizou
      conout("*** NAO AUTORIZADO EXAME ***")
      cCodErro := MsgErro(aRet[4,1,2])
      ConOut("erro POS aDados : "+cCodErro)
      PlsPosPut("CODRES",MsgErro(aRet[4,1,2]),aDados)
      PlsPosPut("NUMDOC","000000000",aDados)   // NUMERO DA AUTORIZACAO
      For nI := 1 to Len(aItens)
         PlsPosPut("CODAUT",cCodErro,aItens[nI])
      Next
   EndIf
ElseIf PlsPOSGet("CODTRANS",aDados) == "0705" // Pedido de autorizacao de materiais
   cCodInt := SubStr(PlsPOSGet("TRILHACAR",aDados),1,4)
   cCodUsu := SubStr(PlsPOSGet("TRILHACAR",aDados),1,17)
   cData := PlsPOSGet("DATA",aDados)
   dData := CtoD(SubStr(cData,1,2)+"/"+SubStr(cData,3,2)+"/"+SubStr(cData,5,4))
   aadd(aCab,{"OPEMOV",cCodInt})
   aadd(aCab,{"USUARIO",cCodUsu})
   aadd(aCab,{"DATPRO",dData })
   aadd(aCab,{"HORAPRO",PlsPOSGet("HORAPRO",aDados)})
   aadd(aCab,{"CIDPRI",NIL })
   aadd(aCab,{"CODRDA",NIL })
   cCodPro := GetNewPar("MV_PLSCDMT",'')   // PARAMETRO QUE INFORMA CODIGO PARA AUTORIZACAO DE MATERIAIS/MEDICAMENTOS
   aadd(aIte,{"SEQMOV",01 })
   aadd(aIte,{"CODPAD",SubStr(cCodPro,1,2)  })
   aadd(aIte,{"CODPRO",SubStr(cCodPro,3)  })
   aadd(aIte,{"QTD",Val(PlsPOSGet("VALORMAT",aDados)) })
   aRet := PLSXAUTP(aCab,aIte)
   
   If aRet[1]   // autorizou
      conout("*** AUTORIZADO ***")
      PlsPosPut("CODRES","00",aDados)
      PlsPosPut("FLAGCONS","N",aDados)
      PlsPosPut("NUMDOC",aRet[2],aDados)   // NUMERO DA AUTORIZACAO
   Else  // nao autorizou
      conout("*** NAO AUTORIZADO ***")
      PlsPosPut("NUMDOC","000000000",aDados)   // NUMERO DA AUTORIZACAO
      PlsPosPut("CODRES",MsgErro(aRet[4,1,2]),aDados)
   EndIf
EndIf

Return

User Function PlsEndPos()
Local cDriveProc := ParamIxb[1]
Local cPathOut := ParamIxb[2]
Local cPathIn  := ParamIxb[3]
Local aFilesP
Local nTotFiles
Local nI

 aFilesP := Directory(cDriveProc+cPathOut+'*.Out')
 
 For nI := 1 to len(aFilesP)
    fErase(cPathIn+aFilesP[nI][1])
    If fREname(cDriveProc+cPathOut+aFilesP[nI][1] , cPathIn+aFilesP[nI][1] )#-1
       conout("renomeado para "+cPathIn+aFilesP[nI][1])
    EndIf   
 Next

Return

User Function PlsArqPos()
Local cPathIn := ParamIxb[1]
Local aFiles
aFiles := Directory(cPathIn+'*.in')
Return aFiles


Static Function MsgErro(cCod)
Local aErro := {}
Local nPos
Local cRet

aadd(aErro,{"501","Usuario nao possui cobertura para este procedimento.","21"})
aadd(aErro,{"001","Idade do usuario incompativel com a idade limite para o procedimento.","14"})
aadd(aErro,{"002","Procedimento em carencia para este usuario.","18"})
aadd(aErro,{"003","Sexo invalido para este procedimento.","21"})
aadd(aErro,{"502","Unidade da Rede de atendimento bloqueada.","17"})
aadd(aErro,{"503","Local de atendimento X Rede de atendimento do produto: Invalido.","31"})
aadd(aErro,{"504","Local de atendimento invalido para o produto do usuario.","31"})
aadd(aErro,{"505","Familia bloqueada.","13"})
aadd(aErro,{"506","Usuario bloqueado.","13"})
aadd(aErro,{"507","Operadora invalida para este usuario.","31"})
aadd(aErro,{"508","Matricula do usuario: Invalida.","10"})
aadd(aErro,{"509","Operadora da Rede de atendimento: Invalida.","97"})
aadd(aErro,{"510","Matricula da Rede de atendimento: Invalida.","97"})
aadd(aErro,{"511","Rede de atendimento nao permitida para a operadora informada.","32"})
aadd(aErro,{"512","Rede de atendimento sem local de atendimento cadastrado.","31"})
aadd(aErro,{"513","Rede de atendimento sem especialidade cadastrada","31"})
aadd(aErro,{"004","Critica Financeira.","97"})
aadd(aErro,{"005","Procedimento em carencia para este usuario (PREEXISTENCIA).","18"})
aadd(aErro,{"514","Existe uma internacao para este usuario cuja data de alta encontra-se sem preenchimento.","97"})
aadd(aErro,{"006","Unidade da Rede de atendimento nao autorizada a executar o procedimento.","31"})
aadd(aErro,{"007","Procedimento bloqueado na especialidade de Rede de atendimento.","31"})
aadd(aErro,{"008","Idade do usuario incompativel com a idade limite para a especialidade.","21"})
aadd(aErro,{"009","Sexo invalido para a especialidade.","21"})
aadd(aErro,{"010","A data do evento e anterior a data de inclusao do usuario.","97"})
aadd(aErro,{"515","Nao existe calendario de pagamento para a data do evento informada.","97"})
aadd(aErro,{"516","O Valor do evento esta igual a zero.","23"})
aadd(aErro,{"517","Nao foi encontrada nenhuma ocorrencia para o Codigo da Tabela de Honorarios a ser utilizada.","23"})
aadd(aErro,{"518","Nao existe composicao para esse procedimento.","27"})
aadd(aErro,{"519","A expressao para o Calculo da US em Procedimentos Autorizados na Especialidade da RDA, nao foi informado corretamente.","23"})
aadd(aErro,{"520","A expressao para o Calculo da US em Especialidades na RDA, nao foi informado corretamente.","23"})
aadd(aErro,{"521","A expressao para o Calculo da US no Local de Atendimento na RDA, nao foi informado corretamente.","23"})
aadd(aErro,{"522","A expressao para o Calculo da US em Operadoras na RDA, nao foi informado corretamente.","23"})
aadd(aErro,{"523","A expressao para o Calculo da US em Pacote, nao foi informado corretamente.","23"})
aadd(aErro,{"524","Nao foi informado nenhum valor para a US.","23"})
aadd(aErro,{"525","Nao foi informado nenhum valor para o Filme.","23"})
aadd(aErro,{"526","Nao foi informado nenhum valor para o Porte Anestesico.","23"})
aadd(aErro,{"527","Nao foi informado nenhum valor para o auxiliar.","23"})
aadd(aErro,{"530","Digite verificador da matricula invalido","","23"})
aadd(aErro,{"012","livre p/ uso","98"})
aadd(aErro,{"013","livre p/ uso","98"})
aadd(aErro,{"014","livre p/ uso","98"})
aadd(aErro,{"015","livre p/ uso","98"})
aadd(aErro,{"016","livre p/ uso","98"})
aadd(aErro,{"528","O Procedimento foi negado para ser executado por este prestador no local da atendimento e especialidade.","31"})
aadd(aErro,{"529","A parametrizacao dos niveis de cobranca esta invalida.","98"})
aadd(aErro,{"017","Limite de Quantidade ultrapassada.","24"})
aadd(aErro,{"018","Limite de Periodicidade ultrapassada.","24"})
aadd(aErro,{"019","Limite de Grupo de Quantidade ultrapassada.","24"})
aadd(aErro,{"020","O valor contratato e diferente do valor informado.","23"})
aadd(aErro,{"021","Para este procedimento necessita Guia da Operadora.","14"})
aadd(aErro,{"021","Para este procedimento necessita Auditoria.","14"})
aadd(aErro,{"022","Para este procedimento necessita Guia da Empresa.","14"})
aadd(aErro,{"023","Para este procedimento necessita Guia da Operadora e Empresa.","14"})
aadd(aErro,{"024","Para este procedimento necessita Avaliacao Contratual.","14"})
nPos:=aScan(aErro,{|x|x[1]==cCod})
If nPos == 0
   cRet := "97"
Else
   cRet:= aErro[nPos,3]
EndIf

Return cRet
