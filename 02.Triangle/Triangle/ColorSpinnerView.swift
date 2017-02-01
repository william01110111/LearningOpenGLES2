//
//  ColorSpinnerView.swift
//  Triangle
//
//  Created by William Wold on 1/30/17.
//  Copyright © 2017 BurtK. All rights reserved.
//

import UIKit
import GLKit

class ColorSpinnerView: GLKView {
	
	let vertShaderSrc =
		"attribute vec4 a_Position;         " +
		"void main(void) {                  " +
		"    gl_Position = a_Position;      " +
		"}"
	
	let fragShaderSrc =
		"void main(void) {                       " +
		"    gl_FragColor = vec4(0, 1, 1, 1);    " +
		"}"
	
	let vertices : [Vertex] = [
		Vertex( 0.0,  0.25, 0.0),    // TOP
		Vertex(-0.5, -0.25, 0.0),    // LEFT
		Vertex( 0.5, -0.25, 0.0),    // RIGHT
	]
	
	fileprivate var object = Shape()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	func setup() {
		
		backgroundColor = UIColor.clear
		self.isOpaque = false
		
		self.context = EAGLContext(api: .openGLES2)
		EAGLContext.setCurrent(self.context)
		
		object = Shape(verts: vertices, shader: ShaderProgram(vert: vertShaderSrc, frag: fragShaderSrc))
	}
	
	override func draw(_ rect: CGRect) {
		
		print("OpenGL spinner view drawn")
		
		glClearColor(0.0, 0.0, 1.0, 0.5);
		glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
		
		object.draw()
	}
	
	func BUFFER_OFFSET(_ n: Int) -> UnsafeRawPointer {
		let ptr: UnsafeRawPointer? = nil
		return ptr! + n * MemoryLayout<Void>.size
	}
}

fileprivate class Shape {
	
	var vertexBuffer : GLuint = 0
	var shader = ShaderProgram()
	
	init() {}
	
	init(verts: [Vertex], shader: ShaderProgram) {
		
		self.shader = shader
		
		glGenBuffers(GLsizei(1), &vertexBuffer)
		glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
		let count = verts.count
		let size =  MemoryLayout<Vertex>.size
		glBufferData(GLenum(GL_ARRAY_BUFFER), count * size, verts, GLenum(GL_STATIC_DRAW))
	}
	
	func draw() {
		
		shader.use()
		
		glEnableVertexAttribArray(VertexAttributes.vertexAttribPosition.rawValue)
		
		glVertexAttribPointer(
			VertexAttributes.vertexAttribPosition.rawValue,
			3,
			GLenum(GL_FLOAT),
			GLboolean(GL_FALSE),
			GLsizei(MemoryLayout<Vertex>.size),
			nil
		)
		
		glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
		glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)
		
		glDisableVertexAttribArray(VertexAttributes.vertexAttribPosition.rawValue)
	}
}

fileprivate class ShaderProgram {
	
	var programHandle : GLuint = 0
	
	init() {}
	
	init(vert: String, frag: String) {
		let vertexShaderName = self.compileShader(src: vert, type: GLenum(GL_VERTEX_SHADER))
		let fragmentShaderName = self.compileShader(src: frag, type: GLenum(GL_FRAGMENT_SHADER))
		
		self.programHandle = glCreateProgram()
		glAttachShader(self.programHandle, vertexShaderName)
		glAttachShader(self.programHandle, fragmentShaderName)
		
		glBindAttribLocation(self.programHandle, VertexAttributes.vertexAttribPosition.rawValue, "a_Position") // 정점 보내는 곳을 a_Position 어트리뷰트로 바인딩한다.
		glLinkProgram(self.programHandle)
		
		var linkStatus : GLint = 0
		glGetProgramiv(self.programHandle, GLenum(GL_LINK_STATUS), &linkStatus)
		if linkStatus == GL_FALSE {
			var infoLength : GLsizei = 0
			let bufferLength : GLsizei = 1024
			glGetProgramiv(self.programHandle, GLenum(GL_INFO_LOG_LENGTH), &infoLength)
			
			let info : [GLchar] = Array(repeating: GLchar(0), count: Int(bufferLength))
			var actualLength : GLsizei = 0
			
			glGetProgramInfoLog(self.programHandle, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
			NSLog(String(validatingUTF8: info)!)
			exit(1)
		}
	}
	
	func compileShader(src shaderSrc: String, type shaderType: GLenum) -> GLuint {
	
		let shaderString: NSString = shaderSrc as NSString
		let shaderHandle = glCreateShader(shaderType)
		var shaderStringLength : GLint = GLint(Int32(shaderString.length))
		var shaderCString = shaderString.utf8String
		glShaderSource(
			shaderHandle,
			GLsizei(1),
			&shaderCString,
			&shaderStringLength)
		
		glCompileShader(shaderHandle)
		var compileStatus : GLint = 0
		glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compileStatus)
		
		if compileStatus == GL_FALSE {
			var infoLength : GLsizei = 0
			let bufferLength : GLsizei = 1024
			glGetShaderiv(shaderHandle, GLenum(GL_INFO_LOG_LENGTH), &infoLength)
			
			let info : [GLchar] = Array(repeating: GLchar(0), count: Int(bufferLength))
			var actualLength : GLsizei = 0
			
			glGetShaderInfoLog(shaderHandle, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
			NSLog(String(validatingUTF8: info)!)
			exit(1)
		}
		
		return shaderHandle
	}
	
	func use() {
		glUseProgram(programHandle)
	}
}
