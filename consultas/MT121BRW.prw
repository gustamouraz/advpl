#Include 'Protheus.ch'

/*/{Protheus.doc} MT121BRW

Este ponto de entrada possui a mesma funcionalidade do ponto MT120BRW com o diferencial de que possibilita 
que a rotina MATA121 seja utilizada no Configurador (SIGACFG) para definir regras de Privilégios de acesso 
ao pedido de compras para usuários incluindo o menu personalizado do ponto de entrada.

@author Marcelo
@since 15/08/2015
@version 1.0
/*/

User Function MT121BRW()

	If ExistBlock("GAOWFAPC")
		AAdd( aRotina , { "Env. Email Aprv." , "ExecBlock('GAOWFAPC',.f.,.f.)" , 0 , 0 } )
	EndIf
	// If ExistBlock("ZMBMNU")
	// 	AAdd( aRotina , { "Propostas TI" , "ExecBlock('ZMBMNU',.f.,.f.)" , 0 , 0 } )
	// EndIf
	If ExistBlock("ZZIMNU")
		AAdd( aRotina , { "Compras Pecuária" , "ExecBlock('ZZIMNU',.f.,.f.)" , 0 , 0 } )
	EndIf
Return ( Nil )
