export class CustomError extends Error {

  constructor(status, message) {
    super(message)
    this.status = status
  }

  static BadRequest(message = 'Bad request') {
    return new CustomError(400, message)
  }

  static Unauthorized(message = 'Unauthorized') {
    return new CustomError(401, message)
  }

  static Forbidden(message = 'Forbidden') {
    return new CustomError(403, message)
  }

  static NotFound(message = 'Not found') {
    return new CustomError(404, message)
  }

  static Conflict(message = 'Conflict') {
    return new CustomError(409, message)
  }

  static InternalServerError(message = 'Internal server error') {
    return new CustomError(500, message)
  }
}